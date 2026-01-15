// File: android/app/build.gradle.kts
// ✅ BUILD.GRADLE.KTS YANG SUDAH DIPERBAIKI LENGKAP

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ PERBAIKAN: Plugin sudah dalam format Kotlin DSL yang benar
    id("com.google.gms.google-services")
}

android {
    namespace = "com.company.konseling"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.company.konseling"
        // ✅ Menggunakan minSdkVersion dari Flutter
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        // ✅ Enable MultiDex untuk mengatasi 64k method limit
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Untuk development, gunakan debug signing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BOM untuk version management
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    
    // ✅ Firebase dependencies (version diatur oleh BOM)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    
    // ✅ MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}