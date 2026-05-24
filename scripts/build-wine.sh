#!/bin/bash
# Wine Bionic Builder for Termux + Box64
# Builds x86_64 Wine targeting Android/Bionic libc
# Output packaged for Termux installation

set -euo pipefail

OUT_DIR="${OUT_DIR:-/out}"
mkdir -p "$OUT_DIR"

WINE_VERSION="${WINE_VERSION:-}"
NDK_VERSION="${NDK_VERSION:-r27c}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect Wine version if not specified
if [ -z "$WINE_VERSION" ]; then
  log_info "Detecting latest Wine version..."
  WINE_VERSION=$(curl -s https://dl.winehq.org/wine/source/ | grep -o 'wine-[0-9]\+\(\.[0-9]\+\)*' | sort -V | tail -n1 | sed 's/wine-//')
  if [ -z "$WINE_VERSION" ]; then
    log_error "Failed to detect Wine version"
    exit 1
  fi
fi

log_info "Building Wine $WINE_VERSION for Bionic (x86_64)"

# Check for Android NDK
if [ -z "${NDK_HOME:-}" ]; then
  log_warn "NDK_HOME not set, downloading NDK $NDK_VERSION..."
  wget -q https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip
  unzip -q android-ndk-${NDK_VERSION}-linux.zip
  NDK_HOME=$PWD/android-ndk-${NDK_VERSION}
fi

export PATH="$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

# Download Wine source
log_info "Downloading Wine source..."
WINE_TARBALL="wine-${WINE_VERSION}.tar.xz"
URL="https://dl.winehq.org/wine/source/${WINE_VERSION}/${WINE_TARBALL}"

if ! wget -q "$URL" -O /tmp/$WINE_TARBALL; then
  log_error "Failed to download from $URL"
  exit 1
fi

cd /tmp
tar -xf $WINE_TARBALL
WINE_SRC_DIR=$(tar -tf $WINE_TARBALL | head -1 | cut -f1 -d"/")
cd "$WINE_SRC_DIR"

log_info "Building Wine tools (native)..."
mkdir -p /tmp/wine-tools-build /tmp/wine-tools-install
cd /tmp/wine-tools-build
/tmp/$WINE_SRC_DIR/configure --prefix=/tmp/wine-tools-install --enable-win64 > /dev/null
make -j$(nproc) > /dev/null
make install > /dev/null

export WINE_TOOLS=/tmp/wine-tools-install/bin:$PATH

cd /tmp/$WINE_SRC_DIR

log_info "Configuring Wine for Bionic (cross-compile)..."

# Set cross-compile environment
export CC=x86_64-linux-android24-clang
export CXX=x86_64-linux-android24-clang++
export AR=llvm-ar
export RANLIB=llvm-ranlib
export LD=ld.lld

export CFLAGS="-O2 -fPIC -march=x86-64 -mtune=generic"
export LDFLAGS="-lm"
export CPPFLAGS=""

# Configure Wine with full feature set
./configure \
  --host=x86_64-linux-android \
  --enable-win64 \
  --prefix=/opt/wine \
  --with-freetype \
  --with-xml \
  --with-cups \
  --with-gphoto \
  --with-sane \
  --with-v4l2 \
  --with-gstreamer \
  --with-alsa \
  --with-pulse \
  --with-ncurses \
  --with-gettext \
  --with-osmesa \
  --with-opengl \
  --with-xslt \
  --with-usb \
  --with-dbus \
  --with-vulkan \
  --with-wine-tools=/tmp/wine-tools-install \
  --disable-tests > /dev/null

log_info "Building Wine (this may take a while)..."
make -j$(nproc) 2>&1 | tail -5

log_info "Installing Wine..."
mkdir -p /tmp/wine-install
make install DESTDIR=/tmp/wine-install

# Package for Termux
log_info "Packaging for Termux..."
cd /tmp

# Create package structure
mkdir -p wine-pkg/opt
cp -a wine-install/opt/wine wine-pkg/opt/

cd wine-pkg

# Create tar.xz for Termux installation
tar -cJf "$OUT_DIR/wine-${WINE_VERSION}-bionic-x86_64-termux.tar.xz" .

# Create checksum
cd "$OUT_DIR"
sha256sum wine-${WINE_VERSION}-bionic-x86_64-termux.tar.xz > wine-${WINE_VERSION}-bionic-x86_64-termux.tar.xz.sha256

# Create installation guide
cat > "$OUT_DIR/INSTALL.md" << 'EOFINSTALL'
# Wine Bionic for Termux + Box64

## Installation

```bash
# Extract to Termux $PREFIX
cd $PREFIX
tar -xJf wine-*.tar.xz

# Verify installation
$PREFIX/opt/wine/bin/wine --version
```

## Usage with Box64

```bash
# Single program execution
BOX64_PATH=$PREFIX/opt/wine/bin box64 wine program.exe

# Set permanent alias in ~/.bashrc
echo 'alias wine="BOX64_PATH=\$PREFIX/opt/wine/bin box64 wine"' >> ~/.bashrc
```

## Features

- **Architecture**: x86_64 (AMD64)
- **Runtime**: Bionic libc (Android/Termux compatible)
- **Translator**: Box64 (converts x86_64 to ARM64)
- **Minimal dependencies**: No X11, OpenGL, or audio (can add later if needed)

## Troubleshooting

If Wine fails to start:
1. Check Box64 is installed: `which box64`
2. Verify Wine binary: `file $PREFIX/opt/wine/bin/wine`
3. Check library dependencies: `ldd $PREFIX/opt/wine/bin/wine`

EOFINSTALL

log_info "Build complete!"
ls -lh "$OUT_DIR"/wine-*

