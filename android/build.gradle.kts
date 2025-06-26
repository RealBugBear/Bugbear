// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services Plugin (aktuellste stabile Version)
        classpath("com.google.gms:google-services:4.3.15")
        // Andere Plugins können hier stehen (z.B. Gradle, Crashlytics etc.)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Custom Build-Verzeichnisse für Monorepos o.Ä.
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
