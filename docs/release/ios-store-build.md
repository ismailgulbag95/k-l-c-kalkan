# iOS App Store build

`tool/build_store_ios.sh` creates and verifies a manually signed iOS App Store archive and IPA. It does not upload to App Store Connect or submit a release. The repository intentionally does not choose a publisher's Apple bundle ID, Apple Developer team, signing certificate, or provisioning profile.

## Required publisher inputs

Set these values in the local shell or inject them from the CI secret/configuration store:

| Input | Requirement |
| --- | --- |
| `IOS_BUNDLE_ID` | The publisher's registered, explicit reverse-DNS App ID. The script rejects Apple's `com.example` sample namespace. |
| `IOS_TEAM_ID` | The publisher's 10-character Apple Developer Team ID. |
| `IOS_SIGNING_IDENTITY` | Exact installed identity name, in the form `Apple Distribution: <publisher name> (<TEAM_ID>)`. The corresponding private key must be available in the unlocked keychain. |
| `IOS_PROVISIONING_PROFILE_SPECIFIER` | Exact installed App Store provisioning-profile name or UUID. Use its UUID if profile names are duplicated. |
| `IOS_BUILD_NAME` | Three-part marketing version, such as `1.0.0`. |
| `IOS_BUILD_NUMBER` | Positive integer, unique and higher than every build already uploaded for this App Store app. Keep its counter in CI or another durable release system. |

The bundle ID, team ID, certificate, and profile must belong to the same publisher setup. The profile must authorize the exact app ID and be an App Store distribution profile. Install it at `~/Library/MobileDevice/Provisioning Profiles/`; install and unlock the signing keychain before invoking the script. Keep certificate private keys and CI credentials out of this repository.

Example shell setup (replace every placeholder with the publisher's actual values):

```sh
export IOS_BUNDLE_ID='com.publisher.game'
export IOS_TEAM_ID='<10-character-team-id>'
export IOS_SIGNING_IDENTITY='Apple Distribution: <publisher name> (<10-character-team-id>)'
export IOS_PROVISIONING_PROFILE_SPECIFIER='<installed App Store profile name or UUID>'
export IOS_BUILD_NAME='1.0.0'
export IOS_BUILD_NUMBER='1'

bash tool/build_store_ios.sh
```

The sample values above are illustrative only. Do not use them as the publisher's actual App Store identifiers.

## Host and signing requirements

- Run on macOS with a full Xcode installation selected by `xcode-select`, the iOS device SDK installed, and Xcode's first-launch setup complete.
- Install Flutter on the same runner. The script runs `flutter pub get --enforce-lockfile` before invoking Xcode.
- Make the Apple Distribution identity available in the current unlocked keychain and install its matching App Store profile. The script checks the identity, profile team, app ID, distribution entitlement, archived signature, and exported IPA signature.
- The project and profile need to agree on any App ID capabilities used by the app. Add the publisher's required capabilities and matching profile through the normal Apple Developer workflow before shipping.
- Use a new monotonically increasing `IOS_BUILD_NUMBER` for every upload attempt. A rejected upload still consumes a build number.

The script fails early on non-macOS hosts, missing Xcode/Flutter commands, unset publisher inputs, a sample bundle ID, unavailable signing credentials, or a mismatched provisioning profile. Build or export failures stop the lane with the Xcode error in the output.

## Project settings and identifiers

Only the Runner target's Release configuration reads `IOS_BUNDLE_ID`, `IOS_TEAM_ID`, `IOS_SIGNING_IDENTITY`, and `IOS_PROVISIONING_PROFILE_SPECIFIER`. The build script passes the supplied values to `xcodebuild`; CI can provide the same settings directly for another controlled store-build workflow. Debug and Profile keep the existing local `com.example.ashCircuit` identifier and signing settings. `RunnerTests` keeps its local `com.example.ashCircuit.RunnerTests` identifier in all configurations, so local simulator tests do not require publisher signing inputs.

The existing iOS AppIcon asset catalog remains the app icon source. The script does not create or replace icon assets.

## Output and scope

Successful output is written under `build/ios/store/`:

- `<bundle-id>-<build-number>.xcarchive`
- `<bundle-id>-<build-number>-ipa/Runner.ipa`

It refuses to overwrite either output for a build number that already exists. The IPA is verified for its bundle ID, version, build number, embedded profile, team, and code signature before the script reports success.

App Store Connect API credentials are not needed to create this artifact because this lane does not upload it. Store upload, metadata, privacy declarations, screenshots, review, staged release, and release-health monitoring remain separate release steps. Do not treat a successful archive as App Store submission approval.
