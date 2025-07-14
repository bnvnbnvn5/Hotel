plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = 35 // Cập nhật để khớp với Android SDK Platform 35
    ndkVersion = "27.0.12077973" // Cập nhật để khớp với yêu cầu của path_provider_android và shared_preferences_android

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = 21 // Flutter yêu cầu minSdk 21
        targetSdk = 35 // Cập nhật để khớp với compileSdk
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
}