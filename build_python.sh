git clone https://github.com/66eli77/python-android.git

apt-get update

sudo apt-get install build-essential bison flex autoconf automake autotools-dev quilt libcurl3 curl openssh-server ant mercurial filezilla pure-ftpd dpatch texinfo libncurses5-dev libgmp3-dev libmpfr-dev gawk patchutils binutils-dev zlib1g-dev

sudo apt-get install git-core gnupg gperf libc6-dev x11proto-core-dev libx11-dev libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc libreadline-dev libreadline6 ia32-libs-multiarch libzip-dev libzip-dev libzzip-dev libzzip-0-13

wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip

wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

cd android-ndk-r13b/toolchains

for folder in *-4.6
do
    mv "$folder" "${file%-4.6}-4.4.3"
done

mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-gcc /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-gcc

mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-g++ /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-g++

mv /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-linux-android-strip /android-ndk-r13b/toolchains/x86_64-4.4.3/prebuilt/linux-x86_64/bin/x86_64-strip


mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-g++ /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-g++

mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-gcc /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-gcc

mv /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-linux-android-strip /android-ndk-r13b/toolchains/aarch64-linux-android-4.4.3/prebuilt/linux-x86_64/bin/aarch64-strip

# 1. run bootstrap.sh
source /python-android/bootstrap.sh

sed -i '6s/.*/<uses-sdk android:minSdkVersion="24" />/' /python-android/openssl/AndroidManifest.xml

sed -i '113s/.*/TARGET_LDLIBS := -lz -lc -lm/' /android-ndk-r13b/build/core/default-build-commands.mk

# 2. run build.sh
source /python-android/build.sh

# restore the change
sed -i '113s/.*/TARGET_LDLIBS := -lc -lm/' /android-ndk-r13b/build/core/default-build-commands.mk

# 3. rerun build.sh
source /python-android/build.sh

# 4. run package.sh
source /python-android/package.sh
