FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    ca-certificates \
    git \
    automake \
    autoconf \
    libtool \
    bison \
    flex \
    pkg-config \
    python3 \
    xvfb \
    mesa-utils \
    libfreetype6-dev \
    libglib2.0-dev \
    libx11-dev \
    libxrandr-dev \
    libxrender-dev \
    libxi-dev \
    libxext-dev \
    libxcomposite-dev \
    libxfixes-dev \
    libxdamage-dev \
    libxinerama-dev \
    libxkbcommon-dev \
    libglu1-mesa-dev \
    libosmesa6-dev \
    libpng-dev \
    libjpeg-dev \
    libldap2-dev \
    libgphoto2-dev \
    libv4l-dev \
    libbz2-dev \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/build-wine.sh /build/build-wine.sh
RUN chmod +x /build/build-wine.sh

ENTRYPOINT ["/build/build-wine.sh"]
