import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Cargar key.properties
val keystoreProperties = Properties()

// Opción 1: key.properties en android/key.properties
// val keystorePropertiesFile = rootProject.file("key.properties")

// Opción 2: key.properties en android/app/key.properties
val keystorePropertiesFile = file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("No se encontró key.properties en: ${keystorePropertiesFile.path}")
}

android {
    namespace = "com.pwr.astormobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.pwr.astormobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val alias = keystoreProperties["keyAlias"] as String?
            val keyPass = keystoreProperties["keyPassword"] as String?
            val storeFilePath = keystoreProperties["storeFile"] as String?
            val storePass = keystoreProperties["storePassword"] as String?

            if (alias == null || keyPass == null || storeFilePath == null || storePass == null) {
                throw GradleException(
                    "Faltan campos en key.properties. " +
                    "Se requieren: keyAlias, keyPassword, storeFile, storePassword"
                )
            }

            keyAlias = alias
            keyPassword = keyPass
            storeFile = file(storeFilePath)
            storePassword = storePass
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
        }
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
