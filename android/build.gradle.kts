buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // Phiên bản AGP mới nhất
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0") // Phiên bản Kotlin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Tùy chỉnh thư mục build (giữ nguyên từ code của bạn)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Bỏ evaluationDependsOn(":app") vì không cần thiết trong dự án Flutter tiêu chuẩn
// subprojects {
//     project.evaluationDependsOn(":app")
// }

// Tác vụ clean (giữ nguyên từ code của bạn)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}