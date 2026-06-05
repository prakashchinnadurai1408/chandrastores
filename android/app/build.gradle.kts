plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.chandrastores.smartkirana"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.chandrastores.smartkirana"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("releaseConfig") {
            val storeFilePath = System.getenv("SMART_KIRANA_KEYSTORE")
            if (!storeFilePath.isNullOrBlank()) {
                storeFile = file(storeFilePath)
            }
            storePassword = System.getenv("SMART_KIRANA_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("SMART_KIRANA_KEY_ALIAS")
            keyPassword = System.getenv("SMART_KIRANA_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = if (System.getenv("SMART_KIRANA_KEYSTORE").isNullOrBlank()) {
                signingConfigs.getByName("debug")
            } else {
                signingConfigs.getByName("releaseConfig")
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
