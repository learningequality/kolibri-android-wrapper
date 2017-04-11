# kolibri-android-wrapper

This repo consists of two parts -- Python build for Android; Kolibri Android app. 
* A Docker for cross-compiling Python for Android. The Dockerfile will generate 2 zip files `python_27.zip` and `python_extras_27.zip`
* The kolibri_apk folder contains android-python27 adapted for Kolibri. It uses Gradle build system to generate the APK for Kolibri.
