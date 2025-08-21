plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.nanqipro.ai_english_application"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.nanqipro.ai_english_application"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {

    implementation(libs.appcompat)
    implementation(libs.material)
    
    // Fragment
    implementation("androidx.fragment:fragment:1.6.2")
    
    // RecyclerView
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    
    // CardView
    implementation("androidx.cardview:cardview:1.0.0")
    
    // ConstraintLayout
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    
    // ViewPager2
    implementation("androidx.viewpager2:viewpager2:1.0.0")
    
    // Lifecycle
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.7.0")
    implementation("androidx.lifecycle:lifecycle-livedata:2.7.0")
    
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
}