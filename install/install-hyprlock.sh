#!/usr/bin/env bash

set -e

# Check if running on NixOS
if [ -f /etc/NIXOS ]; then
  echo "NixOS detected. Skipping manual hyprlock installation."
  echo "Use home-manager or system configuration to install hyprlock on NixOS."
  exit 0
fi

echo "Non-NixOS system detected. Building hyprlock from source with system PAM..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "Please run this script as a regular user (it will prompt for sudo when needed)"
  exit 1
fi

# Install build dependencies (based on JaKooLit's Debian-Hyprland script)
echo "Installing build dependencies..."
sudo apt update
sudo apt install -y \
  git \
  cmake \
  pkg-config \
  g++-14 \
  gcc-14 \
  libpam0g-dev \
  libcairo2-dev \
  libpango1.0-dev \
  libgl1-mesa-dev \
  libgles2-mesa-dev \
  libegl1-mesa-dev \
  libdrm-dev \
  libgbm-dev \
  libinput-dev \
  libxkbcommon-dev \
  wayland-protocols \
  libwayland-dev \
  libmagic-dev \
  libzip-dev \
  libjpeg-dev \
  libwebp-dev \
  libfile-mimeinfo-perl \
  libaudit-dev \
  libpugixml-dev \
  libsystemd-dev \
  meson \
  ninja-build

# Use GCC 14 for C++23 support
export CC=/usr/bin/gcc-14
export CXX=/usr/bin/g++-14

# Use system pkg-config for building sdbus-c++ (needs to find system libsystemd)
export PATH="/usr/bin:/usr/local/bin:$PATH"

# Remove old sdbus-c++ if present (to avoid conflicts)
echo "Removing old sdbus-c++ packages if present..."
sudo apt remove -y libsdbus-c++-dev libsdbus-c++1 2>/dev/null || true

# Create temporary build directory
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# Build and install sdbus-c++ 2.0.0
echo "Building sdbus-c++ 2.0.0..."
git clone --depth 1 --branch v2.0.0 https://github.com/Kistler-Group/sdbus-cpp.git
cd sdbus-cpp
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DBUILD_TESTS=OFF \
  -DBUILD_DOC=OFF
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig
cd "$BUILD_DIR"

# Build and install hyprwayland-scanner v0.4.5
echo "Building hyprwayland-scanner v0.4.5..."
git clone --depth 1 --branch v0.4.5 https://github.com/hyprwm/hyprwayland-scanner.git
cd hyprwayland-scanner
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig
cd "$BUILD_DIR"

# Build and install hyprutils v0.8.2
echo "Building hyprutils v0.8.2..."
git clone --depth 1 --branch v0.8.2 https://github.com/hyprwm/hyprutils.git
cd hyprutils
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig
cd "$BUILD_DIR"

# Build and install hyprlang v0.6.4
echo "Building hyprlang v0.6.4..."
git clone --depth 1 --branch v0.6.4 https://github.com/hyprwm/hyprlang.git
cd hyprlang
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig
cd "$BUILD_DIR"

# Build and install hyprgraphics v0.1.6
echo "Building hyprgraphics v0.1.6..."
git clone --depth 1 --branch v0.1.6 https://github.com/hyprwm/hyprgraphics.git
cd hyprgraphics
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig
cd "$BUILD_DIR"

# Build and install hyprlock v0.8.2
echo "Building hyprlock v0.9.2..."
git clone --depth 1 --branch v0.9.2 https://github.com/hyprwm/hyprlock.git
cd hyprlock

# Use only locally built libraries
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"

echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
pkg-config --modversion sdbus-c++ || echo "sdbus-c++ not found via pkg-config"
pkg-config --modversion hyprutils || echo "hyprutils not found via pkg-config"
pkg-config --modversion hyprlang || echo "hyprlang not found via pkg-config"
pkg-config --modversion hyprgraphics || echo "hyprgraphics not found via pkg-config"

# Configure with cmake (matching JaKooLit's approach)
# Add /usr/local/lib to library search path so it finds our sdbus-c++ 2.0.0
cmake --no-warn-unused-cli \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_LIBRARY_PATH=/usr/local/lib \
  -DCMAKE_INCLUDE_PATH=/usr/local/include \
  -S . -B ./build

# Build with parallel processing
cmake --build ./build --config Release --target hyprlock -j$(nproc)

# Install
sudo cmake --install build
sudo ldconfig

# Create PAM configuration if it doesn't exist
if [ ! -f /etc/pam.d/hyprlock ]; then
  echo "Creating PAM configuration..."
  sudo tee /etc/pam.d/hyprlock >/dev/null <<'EOF'
auth sufficient pam_unix.so nullok
auth requisite pam_deny.so
account required pam_unix.so
EOF
fi

# Cleanup
cd /
rm -rf "$BUILD_DIR"

echo "Installation complete!"
echo ""
echo "Installed components (built from source in /usr/local):"
echo "  - sdbus-c++ 2.0.0"
echo "  - hyprwayland-scanner 0.4.5"
echo "  - hyprutils 0.8.2"
echo "  - hyprlang 0.6.4"
echo "  - hyprgraphics 0.1.6"
echo "  - hyprlock 0.8.2 (linked against system PAM)"
echo "  - PAM config -> /etc/pam.d/hyprlock"
echo ""
echo "Make sure /usr/local/lib is in your LD_LIBRARY_PATH or add it to /etc/ld.so.conf.d/"
echo "Run: echo '/usr/local/lib' | sudo tee /etc/ld.so.conf.d/local.conf && sudo ldconfig"
