import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Client identity (applicationId, app name) is generated per build by
// tool/apply_client.dart into client.properties. Defaults below keep
// `flutter run` working before that script has ever been run.
val clientProperties = Properties().apply {
    val file = file("client.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}
val clientApplicationId =
    clientProperties.getProperty("clientApplicationId", "com.example.example_app")
val clientAppName = clientProperties.getProperty("clientAppName", "example_app")

android {
    namespace = "com.example.example_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = clientApplicationId
        resValue("string", "app_name", clientAppName)
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
