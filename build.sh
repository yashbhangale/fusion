#!/bin/bash

# Set default values for customization options
OS_NAME="Custom OS"
LOGO_PATH="/home/fusion/customize/logo.png"
BACKGROUND_PATH="/home/fusion/customize/background.png"
PACKAGE_LIST=""

# Parse command line arguments for customization options
while [[ $# -gt 0 ]]
do
    case "$1" in
        --osName)
            OS_NAME="$2"
            shift 2
            ;;
        --logo)
            LOGO_PATH="$2"
            shift 2
            ;;
        --background)
            BACKGROUND_PATH="$2"
            shift 2
            ;;
        --packages)
            PACKAGE_LIST="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Install required dependencies for live-build (if not already installed)
echo "Installing dependencies..."
apt-get update
apt-get install -y live-build debootstrap

# Setup the directory structure for live-build
BUILD_DIR="/home/fusion/live-build"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Initialize a basic live-build configuration
echo "Initializing live-build configuration..."
lb config

# Custom branding - replace default logo and background
echo "Customizing branding..."

if [ -f "$LOGO_PATH" ]; then
    cp "$LOGO_PATH" "$BUILD_DIR/config/desktop-base/logo.png"
    echo "Logo applied."
else
    echo "No logo found, using default."
fi

if [ -f "$BACKGROUND_PATH" ]; then
    cp "$BACKGROUND_PATH" "$BUILD_DIR/config/desktop-base/background.png"
    echo "Background applied."
else
    echo "No background found, using default."
fi

# Install additional packages if provided
if [ -n "$PACKAGE_LIST" ]; then
    echo "Installing additional packages: $PACKAGE_LIST"
    echo "$PACKAGE_LIST" | tr "," "\n" | while read package; do
        lb config --packages-lists "$package"
    done
fi

# Start the build process
echo "Starting the build process..."
lb build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! The ISO will be available in the $BUILD_DIR directory."
    mv $BUILD_DIR/*.iso /home/fusion/output/my-custom-distro.iso
    echo "ISO saved to /home/fusion/output/my-custom-distro.iso"
else
    echo "Build failed!"
    exit 1
fi
