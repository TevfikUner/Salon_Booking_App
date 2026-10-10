import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter eklentisi Android/Kotlin eklentilerinden sonra gelmeli
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Release imzası: android/key.properties (git'e eklenmez; anahtar deposu repo dışında).
// Dosya yoksa (ör. CI veya başka bir geliştirici) release debug anahtarıyla imzalanır — mağazaya yüklenemez.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.tevfikuner.premiumberber"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion  // 28.2 — kök build.gradle.kts tüm eklentilere de uygular

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.tevfikuner.premiumberber"
        // Firebase alt sınırı 23; Flutter 24 altında uyarı verir → 24 (Android 7.0, cihazların ~%99'u)
        minSdk = 24
        // Google Play 2026 zorunluluğu
        targetSdk = 36
        // pubspec.yaml → version: 1.0.0+1
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
