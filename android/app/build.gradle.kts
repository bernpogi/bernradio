// BERN – Off-Grid Radio · Android app build config
//
// Compatibility:
//   minSdk 24  = Android 7.0 Nougat — the oldest version current Flutter supports.
//   targetSdk  = Flutter's current default (latest), which Google Play requires
//                for new apps and updates. Targeting the latest does NOT drop old
//                phones; minSdk decides that.

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.theprojectnoah.bern_offgrid_radio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.theprojectnoah.bern_offgrid_radio"

        // Android 7.0+. Set explicitly (not flutter.minSdkVersion) so the floor
        // stays fixed even if a future Flutter release changes its default.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO before Play Store release: create an upload keystore and a
            // signingConfigs { create("release") { ... } } block that reads
            // android/key.properties (already git-ignored).
            signingConfig = signingConfigs.getByName("debug")

            // Shrink the APK — helps on older phones with little storage.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}
