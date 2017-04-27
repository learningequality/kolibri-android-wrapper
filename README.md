# kolibri-android-wrapper

To generate the APK, run the following commands:

```
sudo docker build -t kolibriandroid .
sudo docker cp `sudo docker create kolibriandroid`:/kolibri_apk/app/build/outputs/apk/app-debug.apk .
```

---

This wrapper utilizes [SL4A](https://github.com/damonkohler/sl4a) to run python inside Android in order to run Kolibri(a Django server). The wrapper has a simple native Android UI to start the python environment and run Kolibri. You can use Android Studio logcat to debug the python process.

We need to cross-compile python for android and we have [a repo python-android for this](https://github.com/learningequality/python-android). It will generate two zip files `python_27.zip`and `python_extras_27.zip` we need in this repo.

The Kolibri [source code](https://github.com/learningequality/kolibri) is bundled into `Kolibri.pex`.

The Dockerfile will put all 3 of them, `python_27.zip`, `python_extras_27.zip` and `Kolibri.pex` in `/kolibri_apk/app/src/main/res/raw/` to be included in the APK.

# TODOs:

* TODO-1: in `Dockerfile`. Fetch python build and `kolibri.pex` from a better place.

# Recommended IDE
[Android Studio](https://developer.android.com/studio/index.html)

# APK:

The default configuration of this repo is to generate a Android 5.0 and above compatible APK. To generate Android 4.2 and above compatible APK, you need to re-configure the target version in AndroidManifest and Dockerfile, and fetch the compatible python build(since Android 5.0, PIE python build is required). There might be ways to automatize this process via gradle script.

* To generate debuging-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` in `kolibri-android-wrapper/kolibri_apk/app/src/main/java/com/android/kolibri27/config/GlobalConstants.java` to `true`.

* To generate releasing-APK, set `IS_REMOTE_DEBUGGING` and `IS_KOLIBRI_DEBUGGING` to `false`. Obtain a public-key and modify the Dockerfile's `gradlew` command to run a release build.