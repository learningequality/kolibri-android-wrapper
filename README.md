# kolibri-android-wrapper

This repo consists of two parts -- Python build for Android; Kolibri Android app. 
* A Docker for cross-compiling Python for Android. The Dockerfile will generate 2 zip files `python_27.zip` and `python_extras_27.zip`
* The kolibri_apk folder contains android-python27 adapted for Kolibri. It uses Gradle build system to generate the APK for Kolibri.

# TODOs:

* TODO-1: in `Dockerfile`


# APK:

To generate debuging-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` in `kolibri-android-wrapper/kolibri_apk/app/src/main/java/com/android/kolibri27/config/GlobalConstants.java` to `true`.

To generate releasing-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` in `kolibri-android-wrapper/kolibri_apk/app/src/main/java/com/android/kolibri27/config/GlobalConstants.java` to `false`.