#!/bin/bash

echo "---------update-apt-packages-----------"

apt -y update
apt -y --no-install-recommends install software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt -y update \
    && apt -y upgrade \
    && apt -y --no-install-recommends install tzdata \
    && TZ=Etc/UTC \
    && apt -y --no-install-recommends install \
        build-essential \
        ca-certificates \
        cmake \
        cmake-data \
        pkg-config \
        libcurl4 \
        libsm6 \
        libxext6 \
        libssl-dev \
        libffi-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        unzip \
        curl \
        wget \
        # python${PYTHON_VERSION} \
        # python${PYTHON_VERSION}-dev \
        # python${PYTHON_VERSION}-distutils \
        ffmpeg \
#     && ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python \
#     && ln -s /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python \
#     && curl https://bootstrap.pypa.io/get-pip.py | python \
#     && rm -rf /var/lib/apt/lists/* \
#     && ls


echo "---------ln-data-dir------------"

ln -s /mnt/d/Data /fiftyone

ROOT_DIR=/mnt/d/Data/
export FIFTYONE_DATABASE_DIR=${ROOT_DIR}/db \
    FIFTYONE_DEFAULT_DATASET_DIR=${ROOT_DIR}/default \
    FIFTYONE_DATASET_ZOO_DIR=${ROOT_DIR}/zoo/datasets \
    FIFTYONE_MODEL_ZOO_DIR=${ROOT_DIR}/zoo/models \
    FIFTYONE_DATABASE_URI=mongodb://localhost:27017

echo "---------start-fiftyone-server------------"

python ./start.py
# cp start.py /fiftyone/start.py