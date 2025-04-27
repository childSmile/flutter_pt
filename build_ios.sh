#!/bin/bash

# 设置架构和平台 "x86_64"
ARCHS=("arm64" )
SDK="iphoneos"
PLATFORM_PATH=$(xcrun --sdk $SDK --show-sdk-path)
TOOLCHAIN_PATH=$(xcrun -f clang)

# 清理之前的构建输出
rm -rf lib/native/ios
mkdir -p lib/native/ios/Frameworks/libhello.framework/Versions/A/{Headers,Resources}

# 构建静态库
for ARCH in "${ARCHS[@]}"; do
  echo "Building for architecture $ARCH..."
  
  $TOOLCHAIN_PATH \
    -arch $ARCH \
    -isysroot $PLATFORM_PATH \
    -fembed-bitcode \
    -dynamiclib \
    -o lib/native/ios/Frameworks/libhello.framework/Versions/A/libhello_$ARCH \
    lib/native/src/hello.c
  
  if [ $? -ne 0 ]; then
    echo "Build failed for architecture $ARCH"
    exit 1
  fi
done

# 使用 lipo 工具合并不同架构的静态库
lipo -create -output lib/native/ios/Frameworks/libhello.framework/Versions/A/libhello lib/native/ios/Frameworks/libhello.framework/Versions/A/libhello_*

# 创建符号链接
ln -sf A lib/native/ios/Frameworks/libhello.framework/Versions/Current
ln -sf Versions/Current/libhello lib/native/ios/Frameworks/libhello.framework/libhello
ln -sf Versions/Current/Headers lib/native/ios/Frameworks/libhello.framework/Headers

# 复制头文件
cp lib/native/src/hello.h lib/native/ios/Frameworks/libhello.framework/Headers/

echo "Framework created at lib/native/ios/Frameworks/libhello.framework"