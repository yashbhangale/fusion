# fusion

### Pull premade docker image

```
docker pull yashuop/fusionguibuildcontainer:latest
```


### run container locally

```
sudo docker run --privileged -it -v /var/lib/docker/volumes/fusiondata/_data:/home/fusion debian /bin/bash
```

> here my git repo is in folder "/var/lib/docker/volumes/fusiondata/_data" so adjust accordingly


### Basic configurations:

1. Base Distribution: Debian
2. Installer: Calamares
3. Package-manager: apt, apt-get, nala
4. Build tools: live-build, debootstrap, curl, wget, xorriso, syslinux, squashfs-tools, genisoimage

Install build tools inside Docker container   

```
apt update
apt-get install live-build debootstrap curl wget xorriso syslinux squashfs-tools genisoimage git
```


### Build commands 

```
lb config 
lb build --verbose
lb clean
```

Key Files and Directories:

- **config/package-lists/**: You can place custom package lists here to include specific software in the build.
- **config/includes.chroot/**: You can add custom files or scripts to be included in the final system.



### Config file

```
#!/bin/sh

set -e

lb config noauto \
    --distribution bookworm \
    --architecture amd64 \
    --debian-installer false \
    --debian-installer-gui false \
    --bootappend-live "boot=live components persistence" \
    --linux-flavours amd64 \
    --iso-publisher "Fusion Flux" \
    --iso-volume "Fusion Flux Live" \
    --iso-application "Fusion Flux AI/ML Distribution" \
    --apt-indices false \
    --firmware-binary true \
    --firmware-chroot true \
    --archive-areas "main contrib non-free non-free-firmware" \
    "${@}"
```

### **Customizing the Build:**

1. **Window Manager Configuration (i3)**
   Create a `config/package-lists/custom.list.chroot` file and add the packages you want preinstalled in the system:

   ```bash
   mkdir -p config/package-lists
   echo "i3" >> config/package-lists/custom.list.chroot
   echo "lightdm" >> config/package-lists/custom.list.chroot  # For a lightweight display manager
   echo "xterm" >> config/package-lists/custom.list.chroot
   echo "git" >> config/package-lists/custom.list.chroot
   echo "python3" >> config/package-lists/custom.list.chroot
   echo "python3-pip" >> config/package-lists/custom.list.chroot
   echo "python3-venv" >> config/package-lists/custom.list.chroot
   echo "jupyterlab" >> config/package-lists/custom.list.chroot
   echo "neovim" >> config/package-lists/custom.list.chroot
   echo "scikit-learn" >> config/package-lists/custom.list.chroot
   echo "tensorflow" >> config/package-lists/custom.list.chroot
   echo "pytorch" >> config/package-lists/custom.list.chroot
   ```

   This list ensures that the **i3 window manager** is installed, alongside AI/ML-related tools (e.g., `scikit-learn`, `tensorflow`, `pytorch`, and Jupyter).

2. **Add Calamares Installer**
   Calamares is a modular and customizable installer used by various Linux distributions.

   - In your `config/package-lists/`, create a list for Calamares:
     ```bash
     echo "calamares" >> config/package-lists/installer.list.chroot
     echo "calamares-settings-debian" >> config/package-lists/installer.list.chroot
     ```

   - To configure Calamares, you need to create custom settings. Create the following directory:
     ```bash
     mkdir -p config/includes.chroot/etc/calamares/modules
     ```

   - You can find default configurations for Calamares modules in the Debian repository. Customize the installer for your distribution’s needs. For example, place the following configuration in the `netinstall.conf` for Calamares:

     ```bash
     echo "
     ---
     name: netinstall
     welcome: true
     pre_install:
         - initramfs-update
     installation:
         - install
         - configure-base
     post_install:
         - initramfs-update
     " >> config/includes.chroot/etc/calamares/modules/netinstall.conf
     ```

3. **Custom Branding (Replace "Debian" with "Fusion Flux")**
   - Replace any **Debian** branding with **Fusion Flux**. This involves replacing logos, system messages, and installer text.
   - Update the GRUB menu and any logos found in `/boot/grub/themes` and `/usr/share/plymouth/themes` to reflect your distribution’s branding.
   - You can customize `/etc/lsb-release` to define the release version:
     ```bash
     echo "DISTRIB_ID=FusionFlux" > config/includes.chroot/etc/lsb-release
     echo "DISTRIB_DESCRIPTION='Fusion Flux AI/ML Distribution'" >> config/includes.chroot/etc/lsb-release
     ```

4. **Persistence Configuration**
   To ensure USB persistence, ensure the **boot command** includes the persistence option (already included in `--bootappend-live`). Additionally, when users create a live USB with persistence, they need to set up a persistence partition named `persistence`.

   - Modify the live boot files to include support for persistence:
     ```bash
     echo "/ union" > config/includes.binary/persistence.conf
     ```


### correct sources list. Create or edit the file `config/archives/debian.list.chroot`:

```
   deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
   deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
   deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
```


### Testing with qemu 

```
qemu-system-x86_64 -cdrom '/home/fusion/Desktop/live-image-amd64.hybrid.iso' -boot d -m 3000
```