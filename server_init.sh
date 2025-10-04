#!/bin/bash
set -e  # Stop if any command fails

# Go to home directory
cd ~/

# Variables
log_file="server_setup_log.txt"

# Clean up existing data
sudo rm -rf /opt/riscv
sudo rm -rf ~/riscv-gnu-toolchain
rm -f "$log_file"

# Install dependencies
sudo apt update
sudo apt install -y autoconf automake python3 libmpc-dev libmpfr-dev \
    libgmp-dev gawk bison flex texinfo patchutils gcc g++ zlib1g-dev \
    libexpat1-dev libslirp-dev git qemu-user qemu-user-binfmt qemu-system-misc make
echo "Installed dependencies" >> "$log_file"

# Build riscv toolchain from source
sudo mkdir -p /opt/riscv
sudo chown "$(whoami):$(whoami)" /opt/riscv

git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
make clean || true  # Don't fail if no previous build
./configure --prefix=/opt/riscv \
    --with-arch=rv64g --with-abi=lp64
make linux
echo "Built riscv toolchain" >> "$log_file"

# Setup QEMU
sudo systemctl restart systemd-binfmt

# Add tools to PATH (only if not already added)
if ! grep -q "/opt/riscv/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/opt/riscv/bin' >> ~/.bashrc
fi

if ! grep -q "QEMU_LD_PREFIX" ~/.bashrc; then
    echo 'export QEMU_LD_PREFIX=/opt/riscv/sysroot' >> ~/.bashrc
fi

# Load updated environment
source ~/.bashrc

# Create shorthand symlinks
for tool in ar as gcc gdb ld nm objdump readelf strip; do
    sudo ln -sf /opt/riscv/bin/riscv64-unknown-linux-gnu-$tool /opt/riscv/bin/rv-$tool
done
echo "Setup path variables" >> "$log_file"

echo "✅ RISC-V toolchain setup complete."
