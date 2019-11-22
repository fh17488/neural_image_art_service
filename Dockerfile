# Dockerfile with tensorflow gpu support on python3, opencv3.3
FROM tensorflow/tensorflow:1.4.0-py3

MAINTAINER Fergal Cotter <fbc23@cam.ac.uk>

# The code below is all based off the repos made by https://github.com/janza/
# He makes great dockerfiles for opencv, I just used a different base as I need
# tensorflow on a gpu.

RUN apt-get update

# Core linux dependencies.
RUN apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libhdf5-dev \
        libpq-dev

# Python dependencies
RUN pip3 --no-cache-dir install \
    numpy \
    hdf5storage \
    h5py \
    scipy \
    py3nvml \
    flask \
    flask_restful

WORKDIR /
RUN wget https://github.com/opencv/opencv/archive/3.3.0.zip \
	&& unzip 3.3.0.zip \
	&& mkdir /opencv-3.3.0/cmake_binary \
	&& cd /opencv-3.3.0/cmake_binary \
	&& cmake -DBUILD_TIFF=ON \
		  -DBUILD_opencv_java=OFF \
		  -DWITH_CUDA=OFF \
		  -DENABLE_AVX=ON \
		  -DWITH_OPENGL=ON \
		  -DWITH_OPENCL=ON \
		  -DWITH_IPP=ON \
		  -DWITH_TBB=ON \
		  -DWITH_EIGEN=ON \
		  -DWITH_V4L=ON \
		  -DBUILD_TESTS=OFF \
		  -DBUILD_PERF_TESTS=OFF \
		  -DCMAKE_BUILD_TYPE=RELEASE \
		  -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
		  -DPYTHON_EXECUTABLE=$(which python3) \
		  -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
		  -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
	&& make install \
	&& rm /3.3.0.zip \
&& rm -r /opencv-3.3.0


# Clone neural-style app
WORKDIR /app
RUN set -ex && \
        wget --no-check-certificate https://github.com/cysmith/neural-style-tf/archive/master.tar.gz && \
        tar -xvzf master.tar.gz && \
        mv neural-style-tf-master neural-style-tf && \
        rm master.tar.gz

# Download precomputed VGG network weights
WORKDIR /app
RUN set -ex && \
  wget http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-19.mat

#1: Remove extra directories
RUN rm -rf /app/neural-style-tf/stylize_image.sh
RUN rm -rf /app/neural-style-tf/stylize_video.sh
RUN rm -rf /app/neural-style-tf/video_input
RUN rm -rf /app/neural-style-tf/examples
RUN rm -rf /app/neural-style-tf/image_input
RUN rm -rf /app/neural-style-tf/styles

#2: Create required directories
RUN mkdir /app/neural-style-tf/content_image
RUN mkdir /app/neural-style-tf/style_image
RUN mkdir /app/neural-style-tf/result_image

COPY ./neural_style_web.py /app/neural-style-tf
ENV FLASK_APP=/app/neural-style-tf/neural_style_web.py
ENV LC_ALL=C.UTF-8

EXPOSE 5000

#Prepare entry point directory
WORKDIR /app/
CMD cd /app/ && flask run --host=0.0.0.0
