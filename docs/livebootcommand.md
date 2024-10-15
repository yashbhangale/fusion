# build 

```
lb config \
--architecture amd64 \
--distribution bullseye \
--debian-installer live \
--binary-images iso-hybrid \
--bootappend-live "boot=live components locales=en_US.UTF-8 keyboard-layouts=us" \
--debian-installer-gui true \
--archive-areas "main contrib non-free" \
--iso-volume "Fusion Live" \
--iso-application "Fusion Installer" \
--iso-publisher "Fusion Team" \
--iso-preparer "Fusion Team"
```

# source lists
```
nano config/bootstrap
```

```
# config/bootstrap - options for live-build(7), bootstrap stage

LB_ARCHITECTURES="amd64"
LB_BOOTSTRAP_INCLUDE=""
LB_BOOTSTRAP_EXCLUDE=""
LB_BOOTSTRAP_FLAVOUR="minbase"

LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian/"
LB_MIRROR_CHROOT_SECURITY="http://security.debian.org/debian-security/"

```
