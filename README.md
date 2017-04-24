# kolibri-android-wrapper

This repo consists of two parts
* Python build for Android
* Kolibri Android app. 

# TODOs:

* TODO-1: in `Dockerfile`. Fetch `kolibri.pex` from a better place.


# APK:

To generate debuging-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` in `kolibri-android-wrapper/kolibri_apk/app/src/main/java/com/android/kolibri27/config/GlobalConstants.java` to `true`.

To generate releasing-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` to `false`. Obtain a public-key and modify the Dockerfile's `gradlew` command to run a release build.