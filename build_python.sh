git clone https://github.com/66eli77/python-android.git

apt-get update

sudo apt-get install build-essential bison flex autoconf automake autotools-dev quilt libcurl3 curl openssh-server ant mercurial filezilla pure-ftpd dpatch texinfo libncurses5-dev libgmp3-dev libmpfr-dev gawk patchutils binutils-dev zlib1g-dev

sudo apt-get install git-core gnupg gperf libc6-dev x11proto-core-dev libx11-dev libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc libreadline-dev libreadline6 ia32-libs-multiarch libzip-dev libzip-dev libzzip-dev libzzip-0-13

wget https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip

wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

# unpack the downloads
sudo apt-get install unzip
unzip android-ndk-r13b-linux-x86_64.zip
tar -xvzf android-sdk_r24.4.1-linux.tgz

# modify file names in toolchains
cd android-ndk-r13b/toolchains
for folder in *-4.6
do
    mv "$folder" "${file%-4.6}-4.4.3"
done

# back to initial directory
cd ../..

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

# 3. move the PIE enabled files to a save place
mv /python-android/openssl/libs/arm64-v8a/* /PIE/openssl/arm64-v8a/
mv /python-android/openssl/libs/mips/* /PIE/openssl/mips/
mv /python-android/openssl/libs/mips64/* /PIE/openssl/mips64/

mv /python-android/libs/arm64-v8a/* /PIE/libs/arm64-v8a/
mv /python-android/libs/mips/* /PIE/libs/mips/
mv /python-android/libs/mips64/* /PIE/libs/mips64/


# restore the change
sed -i '113s/.*/TARGET_LDLIBS := -lc -lm/' /android-ndk-r13b/build/core/default-build-commands.mk

# 4. rerun build.sh
source /python-android/build.sh

# 5. replace non-PIE files with PIE enabled files we saved earlier
cp /PIE/openssl/arm64-v8a/* /python-android/openssl/libs/arm64-v8a/
cp /PIE/openssl/mips/* /python-android/openssl/libs/mips/
cp /PIE/openssl/mips64/* /python-android/openssl/libs/mips64/

cp /PIE/libs/arm64-v8a/* /python-android/libs/arm64-v8a/
cp /PIE/libs/mips/* /python-android/libs/mips/
cp /PIE/libs/mips64/* /python-android/libs/mips64/

# 6. run package.sh
source /python-android/package.sh
