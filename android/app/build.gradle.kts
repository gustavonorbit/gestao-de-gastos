plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gustavonorbit.gestaodegastos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Avoid stripping native libraries during bundle creation by using legacy
    // JNI packaging. This typically prevents Gradle from attempting to run
    // native symbol stripping which can fail on some toolchains or host setups.
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
        // Ensure Gradle doesn't strip native libraries for the common ABIs.
        // This prevents the 'strip debug symbols' step from running on these files.
        try {
            doNotStrip("**/armeabi-v7a/*.so")
            doNotStrip("**/arm64-v8a/*.so")
            doNotStrip("**/x86/*.so")
            doNotStrip("**/x86_64/*.so")
        } catch (ignored: Throwable) {
            // Some AGP versions may not expose doNotStrip in Kotlin DSL; ignore if unavailable.
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId = "com.gustavonorbit.gestaodegastos"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Enable R8 / ProGuard minification and resource shrinking for release builds.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Disable generation/stripping of native debug symbols for release builds.
            // Setting debugSymbolLevel to 'NONE' prevents Gradle from producing or
            // attempting to strip native debug symbols during the bundle build,
            // which can fail on some build hosts or SDK setups. This change only
            // affects build pipeline behavior and does not modify Flutter app code.
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
    }
}

flutter {
    source = "../.."
}
