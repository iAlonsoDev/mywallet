param(
  [switch]$NoMajor # Si lo pones, no hará upgrades mayores en pubspec
)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host ">> $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "!! $m" -ForegroundColor Yellow }
function Ok($m){ Write-Host "✔ $m" -ForegroundColor Green }

# --- 0) Verificar ubicación ---
$root = (Get-Location).Path
if (!(Test-Path "$root\pubspec.yaml") -or !(Test-Path "$root\android")) {
  throw "Ejecuta este script desde la RAÍZ del proyecto (donde está pubspec.yaml)."
}

# --- 1) Detectar JDK 17 ---
$jdkPath = $null
$adoptium = Get-ChildItem "C:\Program Files\Eclipse Adoptium" -Directory -ErrorAction SilentlyContinue | ? Name -like "jdk-17*"
$msjdk    = Get-ChildItem "C:\Program Files\Microsoft"        -Directory -ErrorAction SilentlyContinue | ? Name -like "jdk-17*"
if ($adoptium) { $jdkPath = $adoptium[0].FullName }
elseif ($msjdk) { $jdkPath = $msjdk[0].FullName }

if (-not $jdkPath) {
  throw "No encontré JDK 17. Instala Temurin o Microsoft OpenJDK 17 y vuelve a correr."
}

Ok "JDK 17 detectado: $jdkPath"

# --- 2) gradle.properties (android/) ---
$gp = "$root\android\gradle.properties"
if (!(Test-Path $gp)) { New-Item $gp -ItemType File | Out-Null }

$gpText = Get-Content $gp -Raw
$gpText = $gpText -replace "(?m)^\s*org\.gradle\.java\.home\s*=.*$", ""
$gpText = $gpText -replace "(?m)^\s*org\.gradle\.jvmargs\s*=.*$", ""
$gpText = $gpText.Trim()

$jdkEsc = $jdkPath -replace "\\","\\\\"  # doble backslash
$gpAdd = @"
org.gradle.java.home=$jdkEsc
org.gradle.jvmargs=-Xmx4G -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
"@.Trim()

if ($gpText.Length -gt 0) { $gpText = "$gpText`r`n$gpAdd" } else { $gpText = $gpAdd }
Set-Content $gp $gpText -Encoding UTF8
Ok "Actualizado android/gradle.properties"

# --- 3) gradle-wrapper.properties (Gradle 8.7) ---
$gwp = "$root\android\gradle\wrapper\gradle-wrapper.properties"
if (!(Test-Path $gwp)) { throw "No existe $gwp" }
$gwpText = Get-Content $gwp -Raw
$gwpText = $gwpText -replace "distributionUrl=.*", "distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip"
Set-Content $gwp $gwpText -Encoding UTF8
Ok "Fijado Gradle wrapper 8.7"

# --- 4) settings.gradle.kts (repos + AGP/Kotlin + resolución kotlin-dsl) ---
$sg = "$root\android\settings.gradle.kts"
if (!(Test-Path $sg)) { throw "No existe $sg (Kotlin DSL). Si usas Groovy, adapta a settings.gradle." }
$sgText = Get-Content $sg -Raw

# Repos pluginManagement
if ($sgText -notmatch "pluginManagement\s*\{") {
  $pm = @"
pluginManagement {
    val props = java.util.Properties()
    file("local.properties").inputStream().use { props.load(it) }
    val flutterSdkPath = props.getProperty("flutter.sdk")
    require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }

    includeBuild("\$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }

    resolutionStrategy {
        eachPlugin {
            if (requested.id.id == "org.gradle.kotlin.kotlin-dsl" && requested.version == "4.5.0") {
                useModule("org.gradle.kotlin:org.gradle.kotlin.gradle.plugin:4.5.0")
            }
        }
    }
}
"@.Trim()
  $sgText = $pm + "`r`n`r`n" + $sgText
} else {
  # Asegurar repos
  if ($sgText -notmatch "gradlePluginPortal\(\)") { $sgText = $sgText -replace "(?s)(pluginManagement\s*\{.*?repositories\s*\{)", "`$1`r`n        gradlePluginPortal()" }
  if ($sgText -notmatch "google\(\)")            { $sgText = $sgText -replace "(?s)(pluginManagement\s*\{.*?repositories\s*\{)", "`$1`r`n        google()" }
  if ($sgText -notmatch "mavenCentral\(\)")      { $sgText = $sgText -replace "(?s)(pluginManagement\s*\{.*?repositories\s*\{)", "`$1`r`n        mavenCentral()" }
  # Añadir resolutionStrategy si no está
  if ($sgText -notmatch "resolutionStrategy\s*\{") {
    $sgText = $sgText -replace "(?s)(pluginManagement\s*\{.*?includeBuild\(.*?\))", "`$1`r`n`r`n    resolutionStrategy {\n        eachPlugin {\n            if (requested.id.id == \"org.gradle.kotlin.kotlin-dsl\" && requested.version == \"4.5.0\") {\n                useModule(\"org.gradle.kotlin:org.gradle.kotlin.gradle.plugin:4.5.0\")\n            }\n        }\n    }"
  }
}

# dependencyResolutionManagement
if ($sgText -notmatch "dependencyResolutionManagement\s*\{") {
  $drm = @"
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}
"@.Trim()
  $sgText = $sgText + "`r`n`r`n" + $drm
}

# Plugins AGP/Kotlin
if ($sgText -notmatch "plugins\s*\{") {
  $pluginsBlock = @"
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.20" apply false
}
"@.Trim()
  $sgText = $sgText + "`r`n`r`n" + $pluginsBlock
} else {
  $sgText = $sgText -replace "id\(\"com\.android\.application\"\)\s+version\s+\"[^\"]+\"", "id(""com.android.application"") version ""8.7.0"""
  $sgText = $sgText -replace "id\(\"org\.jetbrains\.kotlin\.android\"\)\s+version\s+\"[^\"]+\"", "id(""org.jetbrains.kotlin.android"") version ""2.0.20"""
}

Set-Content $sg $sgText -Encoding UTF8
Ok "Actualizado android/settings.gradle.kts"

# --- 5) app/build.gradle.kts (Java 17) ---
$app = "$root\android\app\build.gradle.kts"
if (!(Test-Path $app)) { throw "No existe $app" }
$appText = Get-Content $app -Raw
$appText = $appText -replace "JavaVersion\.VERSION_1?1", "JavaVersion.VERSION_17"
$appText = $appText -replace "jvmTarget\s*=\s*\"11\"", "jvmTarget = \"17\""
Set-Content $app $appText -Encoding UTF8
Ok "Actualizado android/app/build.gradle.kts (Java/Kotlin 17)"

# --- 6) Limpieza & upgrades ---
Info "Limpiando caches locales (proyecto) y paquetes…"
Push-Location $root
& .\android\gradlew --stop | Out-Null
if (Test-Path "$root\.gradle") { Remove-Item "$root\.gradle" -Recurse -Force -ErrorAction SilentlyContinue }

flutter clean
if ($NoMajor) {
  flutter pub upgrade
} else {
  flutter pub upgrade --major-versions
}
dart fix --apply

Ok "Listo. Verificando Gradle/JDK…"
& .\android\gradlew -v

Info "Si JVM no muestra 17, revisa org.gradle.java.home."
Info "Para compilar:"
Write-Host "  flutter run -d ""Pixel 7 Pro""" -ForegroundColor Magenta
Pop-Location
