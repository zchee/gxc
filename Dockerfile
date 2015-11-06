FROM buildpack-deps:wily-scm
MAINTAINER zchee <zchee.io@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		autogen \
		bzip2 \
		dpkg-dev \
		file \
		make \
		p7zip \
		patch \
		pkg-config \
		unzip \
		uuid-dev \
		xz-utils \
		libgmp-dev \
		libmpc-dev \
		libmpfr-dev \
		libssl-dev \
		libtool \
		libxml2-dev \
		zlib1g-dev \
		clang \
		clang-3.7 \
		llvm-dev \
		llvm-3.7-dev \
		libclang-dev \
		libclang1-3.7 \
		libc++-dev \
		g++ \
		gcc \
		g++-5-arm-linux-gnueabi \
		gcc-5-arm-linux-gnueabi \
		g++-5-multilib \
		gcc-5-multilib \
		g++-mingw-w64 \
		gcc-mingw-w64 \
		libc6-dev-armel-cross

RUN ln -s /usr/include/asm-generic /usr/include/asm

# RUN	wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add - && \
# 	apt-get update && apt-get install -y --no-install-recommends \
# 		clang-3.7 \
# 		llvm-3.7-dev \
	# && rm -rf /var/lib/apt/lists/*

# Configure the Go environment, since it's not going to change
ENV PATH   /usr/local/go/bin:$PATH
ENV GOPATH /go

# Inject the remote file fetcher and checksum verifier
ADD script/fetch.sh /fetch.sh
ENV FETCH /fetch.sh
RUN chmod +x $FETCH

# Configure the container for OSX cross compilation
# ENV OSX_SDK_PATH    https://s3.amazonaws.com/andrew-osx-sdks/MacOSX10.9.sdk.tar.xz
# ENV OSX_SDK         MacOSX10.9.sdk

RUN git clone https://github.com/tpoechtrager/osxcross.git

ARG SDK_VERSION
ENV SDK_VERSION ${SDK_VERSION}
ADD SDKs/MacOSX$SDK_VERSION.sdk.tar.xz /osxcross/tarballs/
RUN cd /osxcross/tarballs && \
	tar -cf - * | xz -9 -c - > MacOSX$SDK_VERSION.sdk.tar.xz && \
	rm -rf MacOSX$SDK_VERSION.sdk
# RUN cd /osxcross/tarballs && tar zcf MacOSX$OSX_SDK_VERSION.sdk.tar.xz $OSX_SDK_VERSION

# RUN sed -i -e 's|-march=native||g' /osxcross/build_clang.sh /osxcross/wrapper/build.sh && \
      # UNATTENDED=yes OSX_VERSION_MIN=10.11 /osxcross/build.sh
# RUN UNATTENDED=yes SDK_VERSION=10.11 OSX_VERSION_MIN=10.11 /osxcross/build.sh
ENV MACOSX_DEPLOYMENT_TARGET $SDK_VERSION
RUN UNATTENDED=yes SDK_VERSION=$SDK_VERSION OSX_VERSION_MIN=$SDK_VERSION /osxcross/build.sh
# # OSX_VERSION_MIN=10.6
# # $FETCH $OSX_SDK_PATH e2f01f6dc7611df4783d2adc279d15132f4e9851 && \
# # mv `basename $OSX_SDK_PATH` /osxcross/tarballs/               && \

ENV PATH /osxcross/target/bin:$PATH

# Configure the container for Android cross compilation
ENV ANDROID_NDK       android-ndk-r10e
ENV ANDROID_NDK_PATH  http://dl.google.com/android/ndk/$ANDROID_NDK-linux-x86_64.bin
ENV ANDROID_NDK_ROOT  /usr/local/$ANDROID_NDK
ENV ANDROID_PLATFORM  21
ENV ANDROID_CHAIN_ARM arm-linux-androideabi-4.9

RUN $FETCH $ANDROID_NDK_PATH c685e5f106f8daa9b5449d0a4f21ee8c0afcb2f6 && \
	7zr x `basename $ANDROID_NDK_PATH` \
		"$ANDROID_NDK/build"                                           \
		"$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/include"       \
		"$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi*" \
		"$ANDROID_NDK/prebuilt/linux-x86_64"                           \
		"$ANDROID_NDK/platforms/*/arch-arm"                            \
		"$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM" -o/usr/local > /dev/null && \
	rm -f `basename $ANDROID_NDK_PATH`

ENV PATH /usr/$ANDROID_CHAIN_ARM/bin:$PATH

ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.5.1}
ADD script/go_bootstrap.sh /go_bootstrap.sh
RUN /go_bootstrap.sh

# Inject the old Go package downloader and tool-chain bootstrapper
ADD script/bootstrap.sh /bootstrap.sh
ENV BOOTSTRAP /bootstrap.sh
RUN chmod +x $BOOTSTRAP

# Inject the C dependency cross compiler
ADD script/build_deps.sh /build_deps.sh
ENV BUILD_DEPS /build_deps.sh
RUN chmod +x $BUILD_DEPS

# Inject the container entry point, the build script
ADD script/build.sh /build.sh
ENV BUILD /build.sh
RUN chmod +x $BUILD

ENTRYPOINT ["/build.sh"]
