# ubuntu 14 should come with gcc-4.8, if not, and the build failed, can try install gcc-4.8
from ubuntu:14.04.5

# get the repo
RUN git clone https://github.com/66eli77/python-android.git


# ** generate python_27.zip and python_extras_27.zip **

# install libs
RUN apt-get update
RUN sudo apt-get install build-essential bison flex autoconf automake autotools-dev quilt libcurl3 curl openssh-server ant mercurial filezilla pure-ftpd dpatch texinfo libncurses5-dev libgmp3-dev libmpfr-dev gawk patchutils binutils-dev zlib1g-dev
RUN sudo apt-get install git-core gnupg gperf libc6-dev x11proto-core-dev libx11-dev libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc libreadline-dev libreadline6 ia32-libs-multiarch libzip-dev libzip-dev libzzip-dev libzzip-0-13
# get the right version of NDK and SDK
RUN wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
# unpack the NDK and SDK downloads
RUN sudo apt-get install unzip
RUN unzip android-ndk-r13b-linux-x86_64.zip
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
# modify file names in toolchains
WORKDIR android-ndk-r13b/toolchains
RUN for folder in *-4.6; do mv "$folder" "${file%-4.6}-4.4.3"; done
RUN mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-gcc /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-gcc
RUN mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-g++ /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-g++
RUN mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-strip /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-strip
RUN mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-g++ /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-g++
RUN mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-gcc /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-gcc
RUN mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-strip /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-strip
# 1. run bootstrap.sh
RUN source /python-android/bootstrap.sh
# modify source files
RUN sed -i '6s/.*/<uses-sdk android:minSdkVersion="24" />/' /python-android/openssl/AndroidManifest.xml
RUN sed -i '113s/.*/TARGET_LDLIBS := -lz -lc -lm/' /android-ndk-r13b/build/core/default-build-commands.mk
# 2. run build.sh
RUN source /python-android/build.sh
# 3. move the PIE enabled files to a save place
RUN mv /python-android/openssl/libs/arm64-v8a/* /PIE/openssl/arm64-v8a/
RUN mv /python-android/openssl/libs/mips/* /PIE/openssl/mips/
RUN mv /python-android/openssl/libs/mips64/* /PIE/openssl/mips64/
RUN mv /python-android/libs/arm64-v8a/* /PIE/libs/arm64-v8a/
RUN mv /python-android/libs/mips/* /PIE/libs/mips/
RUN mv /python-android/libs/mips64/* /PIE/libs/mips64/
# restore the change
RUN sed -i '113s/.*/TARGET_LDLIBS := -lc -lm/' /android-ndk-r13b/build/core/default-build-commands.mk
# 4. rerun build.sh
RUN source /python-android/build.sh
# 5. replace non-PIE files with PIE enabled files we saved earlier
RUN cp /PIE/openssl/arm64-v8a/* /python-android/openssl/libs/arm64-v8a/
RUN cp /PIE/openssl/mips/* /python-android/openssl/libs/mips/
RUN cp /PIE/openssl/mips64/* /python-android/openssl/libs/mips64/
RUN cp /PIE/libs/arm64-v8a/* /python-android/libs/arm64-v8a/
RUN cp /PIE/libs/mips/* /python-android/libs/mips/
RUN cp /PIE/libs/mips64/* /python-android/libs/mips64/
# 6. run package.sh
RUN source /python-android/package.sh


# ** generate the APK via Gradle-wrapper**

# copy python build to kolibri app
COPY /python-android/python_27.zip kolibri_apk/app/src/main/res/raw/
COPY /python-android/python_extras_27.zip kolibri_apk/app/src/main/res/raw/
# TODO:
# This is a temporary solution, fetching the kolibri.pex file from Jamie's Slack file share.
ADD https://files.slack.com/files-pri/T0KT5DC58-F4ZTYPAT0/download/kolibri-v0.3.1-beta3.pex kolibri_apk/app/src/main/res/raw/kolibri.pex
# install JDK 8
RUN sudo apt-get install openjdk-8-jdk
# modify gradle.properties file to point to the newly installed JDK 8
WORKDIR /kolibri_apk
RUN sed -i '1s/.*/org.gradle.java.home=/usr/lib/jvm/java-8-openjdk-amd64/' /kolibri_apk/gradle.properties
# create local.properties file to specify SDK path and NDK path
RUN printf "ndk.dir=/android-ndk-r13b\nsdk.dir=/android-sdk-linux" > local.properties
# generate a debugging APK
RUN ./gradlew assembleDebug