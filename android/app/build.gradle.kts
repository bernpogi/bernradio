// BERN – Off-Grid Radio · Android app build config
// (Follows the current Flutter template: AGP 9, built-in Kotlin, Java 17.)
//
// Compatibility:
//   minSdk 24  = Android 7.0 Nougat — the oldest version current Flutter supports.
//   targetSdk  = Flutter's current default (latest), which Google Play requires
//                for new apps and updates. Targeting the latest does NOT drop old
//                phones; minSdk decides that.

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.theprojectnoah.bern_offgrid_radio"
    // 37 is required by permission_handler 13+ (see its changelog). compileSdk only
    // controls which APIs the code can reference; it does not affect which phones
    // can install the app (that is minSdk below).
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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
            // release signing config that reads android/key.properties (git-ignored).
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
