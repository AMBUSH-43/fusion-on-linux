#!/bin/bash
# Fusion 360 on Ubuntu 24.04 — One-line installer
# Tested: Ryzen 7 + NVIDIA RTX 3050 + Ubuntu 24.04 LTS
# Credit: designgears/Autodesk-Fusion-360-for-Linux

set -e

echo "========================================"
echo " Fusion 360 Ubuntu 24.04 Installer"
echo "========================================"

# Step 1: Check NVIDIA driver
echo "[1/4] Checking NVIDIA driver..."
if ! nvidia-smi &>/dev/null; then
  echo "ERROR: NVIDIA driver not found. Install it first:"
  echo "  sudo ubuntu-drivers autoinstall && sudo reboot"
  echo "  Then disable Secure Boot in BIOS and re-run this script."
  exit 1
fi
echo "✓ NVIDIA driver OK"

# Step 2: Install base deps
echo "[2/4] Installing base dependencies..."
sudo apt update -qq
sudo apt install -y ca-certificates curl wget cabextract

# Step 3: Replace Snap Firefox with DEB
echo "[3/4] Setting up Firefox DEB..."
if snap list firefox &>/dev/null 2>&1; then
  sudo snap remove firefox --purge || true
fi

if ! dpkg -l firefox 2>/dev/null | grep -q "^ii"; then
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
    sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] \
    https://packages.mozilla.org/apt mozilla main" | \
    sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
  sudo apt update -qq
  sudo apt install -y --allow-downgrades firefox
fi
echo "✓ Firefox DEB OK"

# Step 4: Run patched installer
echo "[4/4] Running Fusion 360 patched installer..."
echo "This will download ~2.2GB and take 15-30 minutes. Do NOT close this terminal."
echo ""
cd ~
curl -L https://raw.githubusercontent.com/designgears/Autodesk-Fusion-360-for-Linux/main/files/setup/autodesk_fusion_installer_x86-64.sh \
  -o fusion_patched.sh
chmod +x fusion_patched.sh
./fusion_patched.sh --install-fix --default

echo ""
echo "========================================"
echo " Installation complete!"
echo " Launch: ~/.autodesk_fusion/autodesk_fusion_launcher.sh"
echo " Or find 'Autodesk Fusion' in your apps menu"
echo "========================================"
