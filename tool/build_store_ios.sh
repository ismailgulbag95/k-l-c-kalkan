#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  printf 'build_store_ios: ERROR: %s\n' "$*" >&2
  exit 1
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "This store build requires macOS with Xcode; current OS is $(uname -s). Run it on a macOS CI runner or Mac."
fi

for tool_name in xcodebuild xcode-select flutter security codesign ditto grep; do
  command -v "$tool_name" >/dev/null 2>&1 || fail "Required command '$tool_name' is missing. Install/configure Xcode and Flutter on this Mac."
done

DEVELOPER_DIR_PATH="$(xcode-select -p 2>/dev/null)" || fail "No active Xcode developer directory. Select a full Xcode installation with xcode-select."
[[ -d "$DEVELOPER_DIR_PATH" ]] || fail "The active Xcode developer directory does not exist: $DEVELOPER_DIR_PATH"
XCODE_VERSION="$(xcodebuild -version 2>&1)" || fail "xcodebuild could not start. Finish Xcode's first-launch setup and accept its license."
IOS_SDK_LIST="$(xcodebuild -showsdks 2>&1)" || fail "Could not query Xcode SDKs. Check the Xcode installation."
printf '%s\n' "$IOS_SDK_LIST" | grep -q 'iphoneos' || fail "The active Xcode installation has no iOS device SDK. Install the iOS platform in Xcode."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_PATH="$ROOT_DIR/ios/Runner.xcworkspace"
[[ -d "$WORKSPACE_PATH" ]] || fail "Flutter iOS workspace not found at $WORKSPACE_PATH"

for required_name in IOS_BUNDLE_ID IOS_TEAM_ID IOS_SIGNING_IDENTITY IOS_PROVISIONING_PROFILE_SPECIFIER IOS_BUILD_NAME IOS_BUILD_NUMBER; do
  [[ -n "${!required_name:-}" ]] || fail "Required input $required_name is empty. See docs/release/ios-store-build.md."
done

[[ "$IOS_BUNDLE_ID" =~ ^[A-Za-z0-9][A-Za-z0-9-]*(\.[A-Za-z0-9][A-Za-z0-9-]*)+$ ]] || fail "IOS_BUNDLE_ID must be a reverse-DNS bundle identifier, such as studio-name.game-name."
case "$IOS_BUNDLE_ID" in
  com.example|com.example.*) fail "IOS_BUNDLE_ID still uses Apple's sample com.example namespace. Set the publisher's registered App ID." ;;
esac
[[ "$IOS_TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || fail "IOS_TEAM_ID must be the publisher's 10-character Apple Developer Team ID."
[[ "$IOS_SIGNING_IDENTITY" == "Apple Distribution: "* ]] || fail "IOS_SIGNING_IDENTITY must be the exact Apple Distribution certificate name."
[[ "$IOS_SIGNING_IDENTITY" == *"($IOS_TEAM_ID)" ]] || fail "IOS_SIGNING_IDENTITY must end with the supplied Apple Team ID in parentheses."
[[ "$IOS_BUILD_NAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "IOS_BUILD_NAME must be a three-part version such as 1.2.3."
[[ "$IOS_BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || fail "IOS_BUILD_NUMBER must be a positive integer that is higher than every build already uploaded for this app."

IDENTITIES="$(security find-identity -v -p codesigning 2>&1)" || fail "Could not read code-signing identities from the current keychain. Unlock the CI keychain and install the publisher's signing certificate."
printf '%s\n' "$IDENTITIES" | grep -Fq -- "$IOS_SIGNING_IDENTITY" || fail "The requested Apple Distribution identity is not available as a valid identity in the current keychain: $IOS_SIGNING_IDENTITY"

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
[[ -d "$PROFILE_DIR" ]] || fail "No provisioning profiles are installed at $PROFILE_DIR. Install the App Store profile before building."
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/kul-cemberi-ios-store.XXXXXX")" || fail "Could not create a temporary directory."
trap 'rm -rf "$TEMP_DIR"' EXIT

PROFILE_DECODED="$TEMP_DIR/profile.plist"
PROFILE_UUID=""
PROFILE_MATCH_COUNT=0
for profile_path in "$PROFILE_DIR"/*.mobileprovision; do
  [[ -f "$profile_path" ]] || continue
  security cms -D -i "$profile_path" > "$PROFILE_DECODED" 2>/dev/null || continue
  profile_uuid="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$PROFILE_DECODED" 2>/dev/null || true)"
  profile_name="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$PROFILE_DECODED" 2>/dev/null || true)"
  if [[ "$profile_uuid" == "$IOS_PROVISIONING_PROFILE_SPECIFIER" || "$profile_name" == "$IOS_PROVISIONING_PROFILE_SPECIFIER" ]]; then
    PROFILE_MATCH_COUNT=$((PROFILE_MATCH_COUNT + 1))
    PROFILE_UUID="$profile_uuid"
    PROFILE_TEAM_ID="$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$PROFILE_DECODED" 2>/dev/null || true)"
    PROFILE_APP_IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$PROFILE_DECODED" 2>/dev/null || true)"
    PROFILE_GET_TASK_ALLOW="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:get-task-allow' "$PROFILE_DECODED" 2>/dev/null || true)"
    [[ "$PROFILE_TEAM_ID" == "$IOS_TEAM_ID" ]] || fail "The selected provisioning profile belongs to team '$PROFILE_TEAM_ID', not IOS_TEAM_ID '$IOS_TEAM_ID'."
    [[ "$PROFILE_APP_IDENTIFIER" == *".$IOS_BUNDLE_ID" ]] || fail "The selected provisioning profile App ID '$PROFILE_APP_IDENTIFIER' does not match IOS_BUNDLE_ID '$IOS_BUNDLE_ID'."
    [[ "$PROFILE_GET_TASK_ALLOW" == "false" ]] || fail "The selected provisioning profile is not an App Store distribution profile (get-task-allow must be false)."
  fi
done
[[ "$PROFILE_MATCH_COUNT" -gt 0 ]] || fail "No installed provisioning profile matched IOS_PROVISIONING_PROFILE_SPECIFIER '$IOS_PROVISIONING_PROFILE_SPECIFIER'. Supply its exact name or UUID."
[[ "$PROFILE_MATCH_COUNT" -eq 1 ]] || fail "More than one installed profile matched '$IOS_PROVISIONING_PROFILE_SPECIFIER'. Use the profile UUID to select one unambiguously."
[[ "$PROFILE_UUID" =~ ^[A-Fa-f0-9-]+$ ]] || fail "The selected provisioning profile did not contain a valid UUID."

cd "$ROOT_DIR"
flutter pub get --enforce-lockfile || fail "flutter pub get failed. Resolve the locked dependencies before making a store archive."

OUTPUT_DIR="$ROOT_DIR/build/ios/store"
ARCHIVE_PATH="$OUTPUT_DIR/$IOS_BUNDLE_ID-$IOS_BUILD_NUMBER.xcarchive"
EXPORT_PATH="$OUTPUT_DIR/$IOS_BUNDLE_ID-$IOS_BUILD_NUMBER-ipa"
DERIVED_DATA_PATH="$OUTPUT_DIR/DerivedData-$IOS_BUNDLE_ID-$IOS_BUILD_NUMBER"
[[ ! -e "$ARCHIVE_PATH" ]] || fail "Archive output already exists: $ARCHIVE_PATH. Use a new monotonic build number or move the previous artifact."
[[ ! -e "$EXPORT_PATH" ]] || fail "IPA export output already exists: $EXPORT_PATH. Use a new monotonic build number or move the previous artifact."
mkdir -p "$OUTPUT_DIR"

EXPORT_OPTIONS_PATH="$TEMP_DIR/ExportOptions.plist"
cat > "$EXPORT_OPTIONS_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>teamID</key>
  <string>$IOS_TEAM_ID</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>$IOS_BUNDLE_ID</key>
    <string>$PROFILE_UUID</string>
  </dict>
</dict>
</plist>
PLIST

printf 'Building %s (%s, build %s) with %s\n' "$IOS_BUNDLE_ID" "$IOS_BUILD_NAME" "$IOS_BUILD_NUMBER" "$XCODE_VERSION"
xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  archive \
  IOS_BUNDLE_ID="$IOS_BUNDLE_ID" \
  IOS_TEAM_ID="$IOS_TEAM_ID" \
  IOS_SIGNING_IDENTITY="$IOS_SIGNING_IDENTITY" \
  IOS_PROVISIONING_PROFILE_SPECIFIER="$PROFILE_UUID" \
  FLUTTER_BUILD_NAME="$IOS_BUILD_NAME" \
  FLUTTER_BUILD_NUMBER="$IOS_BUILD_NUMBER" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$IOS_TEAM_ID" \
  CODE_SIGN_IDENTITY="$IOS_SIGNING_IDENTITY" \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_UUID" || fail "Xcode archive failed. Review the signing or Flutter build error above."

ARCHIVED_APP_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app"
[[ -d "$ARCHIVED_APP_PATH" ]] || fail "Xcode reported archive success but Runner.app is missing from the archive."

verify_signed_app() {
  local app_path="$1"
  local label="$2"
  local info_plist="$app_path/Info.plist"
  local bundle_id
  local version_name
  local build_number
  local signature_details
  local team_identifier
  local embedded_profile="$TEMP_DIR/embedded-$RANDOM.plist"
  local embedded_team
  local embedded_app_identifier
  local embedded_get_task_allow

  [[ -f "$info_plist" ]] || fail "$label is missing Info.plist."
  /usr/bin/codesign --verify --deep --strict "$app_path" || fail "$label has an invalid or incomplete code signature."
  signature_details="$(/usr/bin/codesign -dv --verbose=4 "$app_path" 2>&1)" || fail "Could not inspect the $label code signature."
  printf '%s\n' "$signature_details" | grep -Fq -- "Authority=$IOS_SIGNING_IDENTITY" || fail "$label is not signed by IOS_SIGNING_IDENTITY."
  team_identifier="$(printf '%s\n' "$signature_details" | sed -n 's/^TeamIdentifier=//p')"
  [[ "$team_identifier" == "$IOS_TEAM_ID" ]] || fail "$label signature TeamIdentifier '$team_identifier' does not match IOS_TEAM_ID '$IOS_TEAM_ID'."

  bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$info_plist" 2>/dev/null || true)"
  version_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$info_plist" 2>/dev/null || true)"
  build_number="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$info_plist" 2>/dev/null || true)"
  [[ "$bundle_id" == "$IOS_BUNDLE_ID" ]] || fail "$label bundle identifier '$bundle_id' does not match IOS_BUNDLE_ID '$IOS_BUNDLE_ID'."
  [[ "$version_name" == "$IOS_BUILD_NAME" ]] || fail "$label version '$version_name' does not match IOS_BUILD_NAME '$IOS_BUILD_NAME'."
  [[ "$build_number" == "$IOS_BUILD_NUMBER" ]] || fail "$label build number '$build_number' does not match IOS_BUILD_NUMBER '$IOS_BUILD_NUMBER'."

  [[ -f "$app_path/embedded.mobileprovision" ]] || fail "$label has no embedded provisioning profile."
  security cms -D -i "$app_path/embedded.mobileprovision" > "$embedded_profile" 2>/dev/null || fail "$label contains an unreadable provisioning profile."
  [[ "$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$embedded_profile" 2>/dev/null || true)" == "$PROFILE_UUID" ]] || fail "$label does not contain the selected provisioning profile."
  embedded_team="$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$embedded_profile" 2>/dev/null || true)"
  embedded_app_identifier="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$embedded_profile" 2>/dev/null || true)"
  embedded_get_task_allow="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:get-task-allow' "$embedded_profile" 2>/dev/null || true)"
  [[ "$embedded_team" == "$IOS_TEAM_ID" ]] || fail "$label embedded profile has the wrong team."
  [[ "$embedded_app_identifier" == *".$IOS_BUNDLE_ID" ]] || fail "$label embedded profile does not authorize IOS_BUNDLE_ID."
  [[ "$embedded_get_task_allow" == "false" ]] || fail "$label embedded profile is not for distribution."
}

verify_signed_app "$ARCHIVED_APP_PATH" "Xcode archive"

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PATH" || fail "Xcode IPA export failed. Review the export or signing error above."

IPA_PATH="$EXPORT_PATH/Runner.ipa"
[[ -s "$IPA_PATH" ]] || fail "Xcode export completed but Runner.ipa is missing or empty."
EXTRACTED_IPA_DIR="$TEMP_DIR/exported-ipa"
mkdir -p "$EXTRACTED_IPA_DIR"
ditto -x -k "$IPA_PATH" "$EXTRACTED_IPA_DIR" || fail "Could not inspect the exported IPA."
verify_signed_app "$EXTRACTED_IPA_DIR/Payload/Runner.app" "Exported IPA"

printf 'Store-ready IPA: %s\nArchive: %s\n' "$IPA_PATH" "$ARCHIVE_PATH"
