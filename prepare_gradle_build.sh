# install Java JDK 8
apt-get update

sudo apt-get install openjdk-8-jdk

# modify gradle.properties file to point to the newly installed JDK 8
sed -i '1s/.*/org.gradle.java.home=/usr/lib/jvm/java-8-openjdk-amd64/' /kolibri_apk/gradle.properties

# create local.properties file to specify SDK path and NDK path
printf "ndk.dir=/android-ndk-r13b\nsdk.dir=/android-sdk-linux" > local.properties
