// --- settings.gradle.kts (completo y válido) ---

pluginManagement {
    val props = java.util.Properties()
    file("local.properties").inputStream().use { props.load(it) }
    val flutterSdkPath = props.getProperty("flutter.sdk")
        ?: error("flutter.sdk not set in local.properties")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }

    // Red de seguridad para el kotlin-dsl 4.5.0
    resolutionStrategy {
        eachPlugin {
            if (
                requested.id.id == "org.gradle.kotlin.kotlin-dsl" &&
                requested.version == "4.5.0"
            ) {
                useModule("org.gradle.kotlin:org.gradle.kotlin.gradle.plugin:4.5.0")
            }
        }
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Repo del engine de Flutter (necesario para io.flutter:*)
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
    }
}

// Bloque plugins debe estar a nivel raíz (top-level), no dentro de otros bloques
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

rootProject.name = "android"
include(":app")
