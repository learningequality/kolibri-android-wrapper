# ubuntu 14 should come with gcc-4.8, if not, and the build failed, can try install gcc-4.8
FROM ubuntu:14.04.5

# install required ubuntu packages
RUN apt-get update
RUN sudo apt-get install -y wget unzip software-properties-common

# get the right version of NDK and SDK
RUN wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
# unpack the NDK and SDK downloads
RUN unzip android-ndk-r13b-linux-x86_64.zip
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz

# TODO:
# This is a temporary solution to fetch python build and kolibri.pex
# fetching python build
ADD https://github.com/learningequality/python-android/releases/download/1/python_27.zip /kolibri_apk/app/src/main/res/raw/
ADD https://github.com/learningequality/python-android/releases/download/1/python_extras_27.zip /kolibri_apk/app/src/main/res/raw/

COPY *.pex .
RUN export PEX_PATH=$(ls *.pex | awk "{ print $1 }")
RUN export PEX_VERSION_STRING="${PEX_PATH%.*}"
COPY $PEX_PATH kolibri_apk/app/src/main/res/raw/kolibri.pex

# install JDK 8
RUN sudo apt-add-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-installer
RUN apt-get clean
# Copy kolibri_apk into the container
ADD /kolibri_apk/. /kolibri_apk
# modify gradle.properties file to point to the newly installed JDK 8
WORKDIR /kolibri_apk
RUN sed -i '1s@.*@org.gradle.java.home=/usr/lib/jvm/java-8-oracle@' /kolibri_apk/gradle.properties
# create local.properties file to specify SDK path and NDK path
RUN printf "ndk.dir=/android-ndk-r13b\nsdk.dir=/android-sdk-linux" > local.properties
# configure SDK
RUN echo y | /android-sdk-linux/tools/android update sdk --all --filter platform-tools,build-tools-25.0.0,android-22 --no-ui --force
# generate a debugging APK
RUN ./gradlew assembleDebug

RUN cp /kolibri_apk/app/build/outputs/apk/app-debug.apk ${PEX_VERSION_STRING}.apk