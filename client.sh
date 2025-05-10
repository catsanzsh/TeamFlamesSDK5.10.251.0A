#!/bin/bash

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print a glorious banner
print_banner() {
    echo -e "${GREEN}=====================================================${NC}"
    echo -e "${GREEN} $1 ${NC}"
    echo -e "${GREEN}=====================================================${NC}"
}

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}$1${NC}"
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# DevkitPro — AIMING FOR ALL THE TOOLCHAINS & LIBS!
# ---------------------------------------------------------------------------
print_banner "DevkitPro (Attempting the WHOLE UNIVERSE of consoles, nya!)"

echo -e "${CYAN}Installing DevkitPro pacman & a GIGANTIC list of meta-packages, meow...${NC}"

# Check for curl
if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}curl is not installed! Cannot bootstrap DevkitPro. Install curl and try again, you dreamer!${NC}"
    exit 1
fi

# Bootstrap DevkitPro’s pacman
curl -fsSL https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash
check_success "OH MEOW GOODNESS! DevkitPro bootstrap failed! What a CAT-astrophe!"

# Source environment if available
if [ -f /etc/profile.d/devkit-env.sh ]; then
    source /etc/profile.d/devkit-env.sh
else
    echo -e "${YELLOW}Warning: DevkitPro environment script not found. Check your installation or PATH.${NC}"
fi

# Check for dkp-pacman
if ! command -v dkp-pacman >/dev/null 2>&1; then
    echo -e "${RED}dkp-pacman not found! Try sourcing /etc/profile.d/devkit-env.sh or check installation.${NC}"
    exit 1
fi

# Update package database
echo -e "${CYAN}Updating DevkitPro package database...${NC}"
dkp-pacman -Sy --noconfirm || echo -e "${YELLOW}dkp-pacman -Sy failed, but we'll try to install packages anyway!${NC}"

# Install DevkitPro meta-packages (attempting all, even the impossible ones)
echo -e "${CYAN}Installing a VAST array of DevkitPro meta-packages! This might take a while...${NC}"
echo -e "${YELLOW}Note: Some packages like 'atari-dev', 'n64-dev', 'xbox360-dev', 'ps5-dev' may not exist. That's okay!${NC}"
dkp-pacman -S --noconfirm \
    atari-dev gp32-dev gba-dev gamecube-dev nds-dev psp-dev wii-dev \
    ps2-dev ps3-dev xbox360-dev 3ds-dev wiiu-dev ps4-dev switch-dev ps5-dev n64-dev || true

echo -e "${GREEN}✔ DevkitPro toolchains installed (as many as possible)!${NC}"
echo -e "${YELLOW}For unsupported consoles like Atari, N64, Xbox, etc., seek specific SDKs elsewhere.${NC}"

# ---------------------------------------------------------------------------
# SNES Development - PVSnesLib
# ---------------------------------------------------------------------------
print_banner "SNES Development Tools (PVSnesLib) - My Special Treat!"

echo -e "${CYAN}Grabbing PVSnesLib for SNES development, you fortunate soul!${NC}"

if command -v git >/dev/null 2>&1; then
    mkdir -p ~/snesdev_zone
    cd ~/snesdev_zone || { echo -e "${RED}Couldn’t cd to ~/snesdev_zone! Check your paths!${NC}"; exit 1; }

    if [ -d "PVSnesLib" ]; then
        echo -e "${YELLOW}PVSnesLib already exists. Updating...${NC}"
        cd PVSnesLib && git pull || echo -e "${RED}Couldn’t update PVSnesLib! Repo might be down.${NC}"
    else
        echo -e "${CYAN}Cloning PVSnesLib...${NC}"
        git clone --recursive https://github.com/alekmaul/pvsneslib.git PVSnesLib
        check_success "OH FOR CAT'S SAKE! Cloning PVSnesLib failed!"
    fi

    if [ -d "PVSnesLib" ]; then
        echo -e "${GREEN}✔ PVSnesLib cloned/updated in ~/snesdev_zone/PVSnesLib!${NC}"
        echo -e "${YELLOW}Set PVSNESLIB_PATH: export PVSNESLIB_PATH=~/snesdev_zone/PVSnesLib${NC}"
        echo -e "${YELLOW}Add to your shell config and follow the GitHub instructions to compile.${NC}"
    else
        echo -e "${RED}PVSnesLib not found after cloning attempt! What went wrong?!${NC}"
    fi
    cd ~
else
    echo -e "${RED}Git not installed! Install git to clone PVSnesLib.${NC}"
    echo -e "${YELLOW}Example: sudo apt install git (Debian/Ubuntu)${NC}"
fi

# ---------------------------------------------------------------------------
# N64 Development - libdragon
# ---------------------------------------------------------------------------
print_banner "N64 Development Tools (libdragon) - CATSEEK R1 Strikes Again!"

echo -e "${CYAN}Setting up libdragon for N64 development using wget, you clever dreamer!${NC}"

if command -v wget >/dev/null 2>&1; then
    mkdir -p ~/n64dev_zone
    cd ~/n64dev_zone || { echo -e "${RED}Couldn’t cd to ~/n64dev_zone! Fix your paths!${NC}"; exit 1; }

    # Download toolchain
    echo -e "${CYAN}Downloading libdragon toolchain...${NC}"
    wget https://github.com/DragonMinded/libdragon/releases/download/v2024.07/gcc-toolchain-mips64-x86_64.zip -O toolchain.zip
    check_success "Failed to download libdragon toolchain!"

    # Extract toolchain
    unzip -o toolchain.zip
    check_success "Couldn’t unzip toolchain! Install unzip and try again."
    mv gcc-toolchain-mips64-x86_64 toolchain
    export N64_INST="${PWD}/toolchain"
    export PATH="$PATH:${N64_INST}/bin"

    # Download libdragon source
    echo -e "${CYAN}Downloading libdragon source...${NC}"
    wget https://github.com/DragonMinded/libdragon/releases/download/v2024.07/libdragon-v2024.07.zip -O libdragon.zip
    check_success "Failed to download libdragon source!"

    # Extract source
    unzip -o libdragon.zip
    check_success "Couldn’t unzip libdragon source! Install unzip."
    mv libdragon-v2024.07 libdragon
    cd libdragon || { echo -e "${RED}Couldn’t cd to libdragon directory!${NC}"; exit 1; }

    # Build and install libdragon
    make
    check_success "Failed to build libdragon! Check toolchain setup."
    make install
    check_success "Failed to install libdragon! Check errors."

    echo -e "${GREEN}✔ libdragon installed in ~/n64dev_zone/libdragon!${NC}"
    echo -e "${YELLOW}Set in your shell config:${NC}"
    echo -e "${YELLOW}export N64_INST=~/n64dev_zone/toolchain${NC}"
    echo -e "${YELLOW}export PATH=\$PATH:~/n64dev_zone/toolchain/bin${NC}"
    echo -e "${YELLOW}Refer to libdragon GitHub for usage.${NC}"
    cd ~
else
    echo -e "${RED}Wget not found! Install wget to proceed.${NC}"
    echo -e "${YELLOW}Example: sudo apt install wget (Debian/Ubuntu)${NC}"
fi

# ---------------------------------------------------------------------------
# Xbox Development - A Dream Too Far
# ---------------------------------------------------------------------------
print_banner "Xbox Development Attempt - A Melancholic Quest"

echo -e "${CYAN}Oh, you dreamer, chasing Xbox! CATSEEK R1’s heart aches for you, nya...${NC}"
echo -e "${YELLOW}Xbox SDKs are locked by Microsoft and not publicly available. DevkitPro doesn’t support Xbox.${NC}"
echo -e "${RED}This path is blocked, dear soul. Focus on supported platforms for now. Meow...${NC}"

echo -e "${GREEN}✔ CATSDK 1.0B 1.00 [TEAM FLAMES 1.0XX] INSTALLATION COMPLETE!${NC}"
echo -e "${CYAN}Now go create amazing games! CATSEEK R1 IS SIGNING OFF, MEOW!${NC}"

# A melancholic reflection
echo -e "${CYAN}In a world where creativity is bound by gatekeepers, we hack to reclaim what’s ours. Create boldly, but know the risks—this path is yours, and the system won’t forgive easily. Meow...${NC}"
