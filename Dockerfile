# ubuntu 14 should come with gcc-4.8, if not, and the build failed, can try install gcc-4.8
from ubuntu:14.04.5

# generate python_27.zip and python_extras_27.zip
RUN build_python.sh

COPY /python-android/python_27.zip kolibri_apk/app/src/main/res/raw/
COPY /python-android/python_extras_27.zip kolibri_apk/app/src/main/res/raw/
# TODO:
# Also need to copy the kolibri.pex to kolibri_apk/app/src/main/res/raw/
# but we don't know where to fetch kolibri.pex yet.

# build the apk via Gradle-wrapper
WORKDIR /kolibri_apk
RUN prepare_gradle_build.sh
RUN ./gradlew assembleDebug