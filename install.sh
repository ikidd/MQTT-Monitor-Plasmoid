#!/bin/bash

# MQTT Monitor KDE Plasmoid installer script

echo "Installing MQTT Monitor KDE Plasmoid..."

# Check if plasmapkg6 or plasmapkg2 is available
if command -v plasmapkg6 &> /dev/null; then
    PLASMAPKG_CMD="plasmapkg6"
elif command -v plasmapkg2 &> /dev/null; then
    PLASMAPKG_CMD="plasmapkg2"
else
    echo "Error: Neither plasmapkg6 nor plasmapkg2 command found."
    echo "Please install plasma-framework package for your distribution."
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "org.kde.plasma.mqttmonitor" ]; then
    echo "Error: org.kde.plasma.mqttmonitor directory not found."
    echo "Please run this script from the root of the project directory."
    exit 1
fi

# Check if metadata.json exists (for Plasma 6) or metadata.desktop (for Plasma 5)
if [ -f "org.kde.plasma.mqttmonitor/metadata.json" ]; then
    echo "Found metadata.json - using Plasma 6 format"
    PLASMA_VERSION=6
elif [ -f "org.kde.plasma.mqttmonitor/metadata.desktop" ]; then
    echo "Found metadata.desktop - using Plasma 5 format"
    PLASMA_VERSION=5
else
    echo "Error: Neither metadata.json nor metadata.desktop found."
    echo "Please make sure the plasmoid files are properly structured."
    exit 1
fi

# Check for Qt MQTT module
echo "Checking for Qt MQTT module..."
if ! qmlscene -I /usr/lib/qt/qml -e "import QtMqtt 6.2; console.log('Qt MQTT module found')" &> /dev/null; then
    echo "Warning: Qt MQTT module might not be installed."
    echo "Please install the Qt MQTT module for your distribution."
    echo "For example:"
    echo "  - Debian/Ubuntu: sudo apt install qt6-mqtt-dev"
    echo "  - Fedora: sudo dnf install qt6-qtmqtt-devel"
    echo "  - Arch Linux: sudo pacman -S qt6-mqtt"
    echo ""
    read -p "Continue with installation anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install or update the plasmoid
if $PLASMAPKG_CMD -l | grep -q org.kde.plasma.mqttmonitor; then
    echo "Updating existing installation..."
    $PLASMAPKG_CMD -u org.kde.plasma.mqttmonitor
else
    echo "Installing new plasmoid..."
    $PLASMAPKG_CMD -i org.kde.plasma.mqttmonitor
fi

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "Installation successful!"
    echo ""
    echo "You may need to restart Plasma to see the widget:"
    echo "kquitapp6 plasmashell || kquitapp5 plasmashell"
    echo "kstart6 plasmashell || kstart5 plasmashell"
    echo ""
    echo "To add the widget to your desktop or panel:"
    echo "1. Right-click on your desktop or panel"
    echo "2. Select 'Add Widgets...'"
    echo "3. Search for 'MQTT Monitor'"
    echo "4. Drag it to your desktop or panel"
else
    echo "Installation failed. Please check the error messages above."
fi