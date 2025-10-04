# Clean up existing data
sudo rm -rf /opt/riscv

# Install dependencies
sudo apt update
sudo apt install autoconf automake python3 libmpc-dev libmpfr-dev \
    libgmp-dev gawk bison flex texinfo patchutils gcc g++ zlib1g-dev \
    libexpat1-dev libslirp-dev git

# Build riscv toolchain from source
sudo mkdir /opt/riscv
sudo chown $(whoami):$(whoami) /opt/riscv

git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
make clean
./configure --prefix=/opt/riscv \
    --with-arch=rv64g --with-abi=lp64 \
    --enable-qemu-system
make linux

# Install QEMU
sudo apt install qemu-user qemu-user-binfmt qemu-system-misc
sudo systemctl restart systemd-binfmt

# Add tools to path
echo 'export PATH=$PATH:/opt/riscv/bin' >> ~/.bashrc
echo 'export QEMU_LD_PREFIX=/opt/riscv/sysroot' >> ~/.bashrc
source ~/.bashrc

for tool in ar as gcc gdb ld nm objdump readelf strip; do
    sudo ln -sf /opt/riscv/bin/riscv64-unknown-linux-gnu-$tool /opt/riscv/bin/rv-$tool
done

