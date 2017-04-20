# ubuntu 14 should come with gcc-4.8, if not, and the build failed, can try install gcc-4.8
from ubuntu:14.04.5

# generate python_27.zip and python_extras_27.zip
RUN build_python.sh

COPY /python-android/python_27.zip kolibri_apk/app/src/main/res/raw/
COPY /python-android/python_extras_27.zip kolibri_apk/app/src/main/res/raw/
# TODO:
# This is a temporary solution, fetching the kolibri.pex file from Jamie's Slack file share.
ADD https://files.slack.com/files-pri/T0KT5DC58-F4ZTYPAT0/download/kolibri-v0.3.1-beta3.pex kolibri_apk/app/src/main/res/raw/kolibri.pex

# build the apk via Gradle-wrapper
WORKDIR /kolibri_apk
RUN ../prepare_gradle_build.sh
RUN ./gradlew assembleDebug