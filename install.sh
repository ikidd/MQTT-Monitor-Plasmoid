#!/bin/bash

# MQTT Monitor KDE Plasmoid installer script

echo "Installing MQTT Monitor KDE Plasmoid..."

# Check if plasmapkg2 is available
if ! command -v plasmapkg2 &> /dev/null; then
    echo "Error: plasmapkg2 command not found."
    echo "Please install plasma-framework package for your distribution."
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "org.kde.plasma.mqttmonitor" ]; then
    echo "Error: org.kde.plasma.mqttmonitor directory not found."
    echo "Please run this script from the root of the project directory."
    exit 1
fi

# Check for Qt MQTT module
echo "Checking for Qt MQTT module..."
if ! qmlscene -I /usr/lib/qt/qml -e "import QtMqtt 5.15; console.log('Qt MQTT module found')" &> /dev/null; then
    echo "Warning: Qt MQTT module might not be installed."
    echo "Please install the Qt MQTT module for your distribution."
    echo "For example:"
    echo "  - Debian/Ubuntu: sudo apt install qtmqtt5-dev"
    echo "  - Fedora: sudo dnf install qt5-qtmqtt-devel"
    echo "  - Arch Linux: sudo pacman -S qt5-mqtt"
    echo ""
    read -p "Continue with installation anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install or update the plasmoid
if plasmapkg2 -l | grep -q org.kde.plasma.mqttmonitor; then
    echo "Updating existing installation..."
    plasmapkg2 -u org.kde.plasma.mqttmonitor
else
    echo "Installing new plasmoid..."
    plasmapkg2 -i org.kde.plasma.mqttmonitor
fi

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "Installation successful!"
    echo ""
    echo "You may need to restart Plasma to see the widget:"
    echo "kquitapp5 plasmashell && kstart5 plasmashell"
    echo ""
    echo "To add the widget to your desktop or panel:"
    echo "1. Right-click on your desktop or panel"
    echo "2. Select 'Add Widgets...'"
    echo "3. Search for 'MQTT Monitor'"
    echo "4. Drag it to your desktop or panel"
else
    echo "Installation failed. Please check the error messages above."
fi