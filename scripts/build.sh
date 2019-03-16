#!/bin/bash

# Modified based on: https://github.com/aeddi/aws-lambda-python-opencv

sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc python-devel chrpath
mkdir -p python/lib/python2.7/site-packages/cv2

pip install numpy sklearn

cp -rf /usr/local/lib64/python2.7/site-packages/numpy python/lib/python2.7/site-packages

 Build OpenCV 3.2
(
    NUMPY=$PWD/python/lib/python2.7/site-packages/numpy/core/include
    cd build
    git clone https://github.com/opencv/opencv
    cd opencv
    git checkout 3.2.0
    cmake                                        \
        -D CMAKE_BUILD_TYPE=RELEASE                \
        -D WITH_TBB=ON                            \
        -D WITH_IPP=ON                            \
        -D WITH_V4L=ON                            \
        -D ENABLE_AVX=ON                        \
        -D ENABLE_SSSE3=ON                        \
        -D ENABLE_SSE41=ON                        \
        -D ENABLE_SSE42=ON                        \
        -D ENABLE_POPCNT=ON                        \
        -D ENABLE_FAST_MATH=ON                    \
        -D BUILD_EXAMPLES=OFF                    \
        -D BUILD_TESTS=OFF                        \
        -D BUILD_PERF_TESTS=OFF                    \
        -D PYTHON2_NUMPY_INCLUDE_DIRS="$NUMPY"    \
        .
    make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
cp opencv/lib/cv2.so python/lib/python2.7/site-packages/cv2/__init__.so
cp -L opencv/lib/*.so.3.2 python/lib/python2.7/site-packages/cv2
strip --strip-all python/lib/python2.7/site-packages/cv2/*
chrpath -r '$ORIGIN' python/lib/python2.7/site-packages/cv2/__init__.so
touch python/lib/python2.7/site-packages/cv2/__init__.py

cp -R /usr/local/lib64/python2.7/site-packages/scipy python/lib/python2.7/site-packages/
cp -R /usr/local/lib64/python2.7/site-packages/sklearn python/lib/python2.7/site-packages/

zip -r lambda-package.zip python/
