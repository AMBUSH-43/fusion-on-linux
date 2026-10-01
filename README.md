# fusion-on-linux# 
Fusion 360 on Ubuntu 24.04 — Complete Working Guide

> **Real-world tested installation guide** — Every error encountered, every fix applied, documented step by step.  
> Hardware tested: **Ryzen 7 + NVIDIA RTX 3050 + Ubuntu 24.04 LTS**

---

## ⚠️ Important: What Doesn't Work (Save Yourself Hours)

Before starting, know what **will fail** so you don't waste time:

| Method | Status | Reason |
|--------|--------|--------|
| Official Autodesk Linux installer | ❌ Doesn't exist | Autodesk doesn't support Linux |
| `cryinkfly` original script | ❌ Broken | Syntax error at line 709 (Firefox detection bug) |
| Stock Wine 9.0 (Ubuntu) | ❌ Crashes | `nujsbridgepythonextension10.pyd` segfault |
| Fusion Client Downloader `.exe` in Wine | ❌ Crashes | Same Python extension crash |
| ProtonGE | ❌ Download links dead | Releases removed |
| Bottles | ❌ Not in Ubuntu repos | Package not available |
| Lutris | ❌ Not listed | Fusion 360 is not a game |

---

## ✅ What Actually Works

### Method: `designgears` Patched Installer (Wine Staging + Custom Wine Build)

Uses a **custom patched Wine build** that specifically fixes the Python extension crash, plus Wine Staging 11.18, WebView2 for login, and DXVK for GPU acceleration.

---

## System Requirements

| Component | Minimum | Tested Setup |
|-----------|---------|--------------|
| OS | Ubuntu 24.04 LTS | Ubuntu 24.04 LTS |
| CPU | 4 cores, 1.7 GHz+ | AMD Ryzen 7 |
| GPU | Dedicated, 4GB VRAM | NVIDIA RTX 3050 (4GB) |
| RAM | 8 GB | 23 GB |
| Disk | 10 GB free | 145 GB free |
| GPU Driver | Latest proprietary | NVIDIA 580.178.04 |

---

## Pre-Installation Steps

### Step 1: Verify NVIDIA Driver

```bash
nvidia-smi
```

Expected output: Your GPU listed with driver version and CUDA version.  
If this fails, install the driver first:

```bash
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo reboot
```

**Critical:** Disable **Secure Boot** in BIOS/UEFI — NVIDIA kernel modules won't load with it enabled.

### Step 2: Install Firefox DEB (replace Snap version)

The installer requires Firefox DEB, not Snap. Do this **before** running the installer:

```bash
# Remove Snap Firefox (force purge to skip snapshot error)
sudo snap remove firefox --purge

# Add Mozilla DEB repo
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
  sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] \
  https://packages.mozilla.org/apt mozilla main" | \
  sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# Install Firefox DEB
sudo apt update
sudo apt install -y --allow-downgrades firefox
```

### Step 3: Install base dependencies

```bash
sudo apt update
sudo apt install -y ca-certificates curl wget cabextract
```

---

## Installation

### Run the Patched Installer

```bash
cd ~
curl -L https://raw.githubusercontent.com/designgears/Autodesk-Fusion-360-for-Linux/main/files/setup/autodesk_fusion_installer_x86-64.sh \
  -o fusion_patched.sh && chmod +x fusion_patched.sh && \
  ./fusion_patched.sh --install-fix --default
```

**What this does automatically:**
- Downloads a custom patched Wine build (~552MB)
- Downloads Wine Staging 11.18 and replaces Ubuntu's Wine 9.0
- Downloads Microsoft WebView2 runtime (~202MB) for the login screen
- Downloads the Fusion 360 installer (~1.5GB)
- Installs DXVK (DirectX → Vulkan translation for your RTX 3050)
- Installs all required fonts and .NET components
- Creates a desktop launcher

**This takes 15–30 minutes depending on your internet speed. Do NOT close the terminal.**

---

## Post-Installation

### Launch Fusion 360

```bash
~/.autodesk_fusion/autodesk_fusion_launcher.sh
```

Or find **Autodesk Fusion** in your applications menu.

### Verify GPU is being used (DXVK active)

```bash
DXVK_HUD=1 ~/.autodesk_fusion/autodesk_fusion_launcher.sh
```

You should see an FPS overlay showing Vulkan and your RTX 3050.

---

## Errors You Will See (All Normal)

These appear in the terminal but **do not affect functionality**:

```
Broken NVIDIA RandR detected, falling back to RandR 1.0
```
→ Wine display scaling warning. Harmless.

```
Could not find Wine Gecko. HTML rendering will be disabled.
```
→ Ignored — WebView2 handles login instead.

```
libEGL warning: egl: failed to create dri2 screen
```
→ EGL fallback warning. DXVK/Vulkan still works.

---

## Errors That WILL Break Things

| Error | Fix |
|-------|-----|
| `nujsbridgepythonextension10.pyd` segfault | Use the `designgears` patched installer, NOT stock Wine |
| `line 709: syntax error near unexpected token }` | The `cryinkfly` script is broken — use `designgears` fork |
| `No address associated with hostname` (Autodesk CDN) | Autodesk blocks some regions — use the GitHub-hosted installer |
| `wine32 has no installation candidate` | Run `sudo dpkg --add-architecture i386` first |

---

## Performance Analysis

| Workload | Performance vs Native Windows |
|----------|-------------------------------|
| CPU (modeling, constraints, sketching) | ~100% — Wine translates API calls, Ryzen 7 runs code natively |
| GPU viewport (DXVK → Vulkan) | ~90–100% — RTX 3050 via direct Vulkan, DXVK sometimes faster than D3D11 |
| Rendering / Simulation | Same as Windows — Autodesk offloads to cloud compute |
| Stability | Community build — occasional UI glitches, not a performance issue |

---

## Uninstall

```bash
./fusion_patched.sh --uninstall
```

---

## ROS 2 Jazzy + Fusion 360 on the Same Machine

If you're also running **ROS 2 Jazzy** on Ubuntu 24.04:

- Install ROS 2 Jazzy **natively on the host** — it's Ubuntu 24.04's Tier 1 platform
- Run Fusion 360 via this guide on the same host
- Wine's dependencies and ROS 2's apt packages don't conflict directly
- If you want full isolation, use **Distrobox** to run Fusion inside a container (shares your kernel and GPU, not a VM)

---

## Contributing

This guide was built from a real, failed-then-succeeded installation session. If you hit new errors or find fixes, PRs welcome.

**Tested on:** Ubuntu 24.04 LTS, Ryzen 7, NVIDIA RTX 3050, Driver 580.178.04  
**Date:** October 2026  
**Installer credit:** [designgears/Autodesk-Fusion-360-for-Linux](https://github.com/designgears/Autodesk-Fusion-360-for-Linux)  
**Original project:** [cryinkfly/Autodesk-Fusion-360-for-Linux](https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux)
