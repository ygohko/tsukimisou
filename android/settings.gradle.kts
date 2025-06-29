pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

/*
import java.util.Properties
import java.io.File

// ':app' モジュールをインクルードします。
include(":app")

// local.properties ファイルのパスを解決します。
// `rootDir` はルートプロジェクトのディレクトリを指すプロパティです。
val localPropertiesFile = File(rootDir, "local.properties")

// ファイルが存在しない場合はビルドを失敗させます。
require(localPropertiesFile.exists()) {
    "local.properties file not found in ${rootDir.path}"
}

// Propertiesオブジェクトを作成し、ファイルを読み込みます。
val properties = Properties()
localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
    properties.load(reader)
}

// local.propertiesからFlutter SDKのパスを取得します。
val flutterSdkPath = properties.getProperty("flutter.sdk")

// flutter.sdkプロパティが設定されていない場合はビルドを失敗させます。
requireNotNull(flutterSdkPath) {
    "flutter.sdk not set in local.properties"
}

// Flutterのプラグインローダースクリプトを適用します。
apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
*/