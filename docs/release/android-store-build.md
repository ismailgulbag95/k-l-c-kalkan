# Android store App Bundle

The repository keeps `com.example.ash_circuit` and debug signing for the existing local release workflow. The dedicated store build opts into a separate signing configuration and requires the publisher's real package ID and upload key before Gradle configures the release variant.

## Publisher inputs required before release

The publisher must obtain and supply all five values below. The application ID must be the final unique Android package ID registered for the app; this repository intentionally does not choose one. The signing values must identify the upload keystore configured for the publisher's Play App Signing setup.

| Value | Environment variable | `android/key.properties` key | Meaning |
|---|---|---|---|
| Publisher package ID | `STORE_APPLICATION_ID` | `storeApplicationId` | Final unique Android application ID |
| Keystore file | `STORE_KEYSTORE_PATH` | `storeFile` | Existing upload keystore path; relative paths are resolved from `android/` |
| Key alias | `STORE_KEY_ALIAS` | `keyAlias` | Alias of the signing key in that keystore |
| Keystore password | `STORE_KEYSTORE_PASSWORD` | `storePassword` | Password that opens the keystore |
| Key password | `STORE_KEY_PASSWORD` | `keyPassword` | Password for the selected key |

Values can be supplied through process environment variables or a local `android/key.properties` file. Environment values take precedence. A local file uses `key=value` lines, for example the five key names in the table; do not add that file or any keystore to version control. `android/.gitignore` already excludes `key.properties` and keystore files. For passwords containing leading/trailing spaces or property-file escape characters, use environment variables.

## Build

From the repository root in PowerShell, run:

```powershell
.\tool\build_store_android.ps1
```

The script rejects missing values, invalid package IDs, Android's sample `com.example` namespace, and missing keystore files before invoking Flutter. It passes credentials to Gradle through process-scoped `ORG_GRADLE_PROJECT_*` environment variables, without placing passwords in command-line arguments or printing them. The resulting bundle is `build/app/outputs/bundle/release/app-release.aab`.

The Gradle configuration also requires an explicit store-lane opt-in (`storeRelease=true`) and validates the package ID and keystore path itself. For a direct Gradle invocation, supply `-PstoreRelease=true` plus `-PstoreApplicationId`, `-PstoreKeystorePath`, `-PstoreKeyAlias`, `-PstoreKeystorePassword`, and `-PstoreKeyPassword`, or set the corresponding environment/local-property values and `STORE_RELEASE=true`.

## Credential handling

Keep the upload keystore and passwords in the publisher's approved encrypted secret store or local ignored files. Never commit them, put them in build scripts, or share them in logs. Back up the upload keystore securely and restrict access to the people and CI identities that need to produce releases. Play App Signing should own the app-signing key; this build should use the publisher's upload key.
