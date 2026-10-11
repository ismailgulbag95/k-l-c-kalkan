import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val storeSigningPropertiesFile = rootProject.file("key.properties")
val storeSigningProperties = Properties().apply {
    if (storeSigningPropertiesFile.isFile) {
        storeSigningPropertiesFile.inputStream().use { load(it) }
    }
}

fun storeValue(projectProperty: String, environmentVariable: String, localProperty: String): String? =
    providers.gradleProperty(projectProperty).orNull?.takeIf(String::isNotBlank)
        ?: providers.environmentVariable(environmentVariable).orNull?.takeIf(String::isNotBlank)
        ?: storeSigningProperties.getProperty(localProperty)?.takeIf(String::isNotBlank)

val storeReleaseRequested =
    providers.gradleProperty("storeRelease").orNull?.toBooleanStrictOrNull() == true ||
        providers.environmentVariable("STORE_RELEASE").orNull?.toBooleanStrictOrNull() == true

val storeApplicationId = storeValue("storeApplicationId", "STORE_APPLICATION_ID", "storeApplicationId")
val storeKeystorePath = storeValue("storeKeystorePath", "STORE_KEYSTORE_PATH", "storeFile")
val storeKeyAlias = storeValue("storeKeyAlias", "STORE_KEY_ALIAS", "keyAlias")
val storeKeystorePassword = storeValue("storeKeystorePassword", "STORE_KEYSTORE_PASSWORD", "storePassword")
val storeKeyPassword = storeValue("storeKeyPassword", "STORE_KEY_PASSWORD", "keyPassword")

if (storeReleaseRequested) {
    val missingValues = buildList {
        if (storeApplicationId == null) add("publisher application ID")
        if (storeKeystorePath == null) add("keystore path")
        if (storeKeyAlias == null) add("key alias")
        if (storeKeystorePassword == null) add("keystore password")
        if (storeKeyPassword == null) add("key password")
    }
    require(missingValues.isEmpty()) {
        "Store release was requested, but required values are missing: ${missingValues.joinToString()}. " +
            "Supply them via Gradle properties, environment variables, or android/key.properties."
    }
    require(storeApplicationId!!.matches(Regex("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+"))) {
        "The store application ID is not a valid Android package ID."
    }
    val normalizedStoreApplicationId = storeApplicationId!!.lowercase()
    require(
        normalizedStoreApplicationId != "com.example" &&
            !normalizedStoreApplicationId.startsWith("com.example."),
    ) {
        "The store application ID must not use Android's sample com.example namespace."
    }
    val resolvedStoreKeystore = rootProject.file(storeKeystorePath!!)
    require(resolvedStoreKeystore.isFile) {
        "The configured store keystore does not exist: ${resolvedStoreKeystore.absolutePath}"
    }
}

android {
    namespace = "com.ismailgulbag.ashcircuit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Unique Application ID for store publishing.
        applicationId = if (storeReleaseRequested) storeApplicationId!! else "com.ismailgulbag.ashcircuit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (storeReleaseRequested) {
        signingConfigs.create("store") {
            storeFile = rootProject.file(storeKeystorePath!!)
            storePassword = storeKeystorePassword!!
            keyAlias = storeKeyAlias!!
            keyPassword = storeKeyPassword!!
        }
    }

    buildTypes {
        release {
            // Keep the existing local release workflow intact. The dedicated store lane
            // opts in explicitly and cannot reach this debug-signing fallback.
            signingConfig = if (storeReleaseRequested) {
                signingConfigs.getByName("store")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
