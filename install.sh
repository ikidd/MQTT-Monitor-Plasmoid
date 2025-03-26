#!/bin/bash

# MQTT Monitor KDE Plasmoid installer script

echo "Installing MQTT Monitor KDE Plasmoid..."

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
            echo "debian"
        elif [[ "$ID" == "fedora" || "$ID_LIKE" == *"fedora"* || "$ID" == "rhel" || "$ID" == "centos" ]]; then
            echo "fedora"
        elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* || "$ID" == "manjaro" ]]; then
            echo "arch"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to install dependencies based on distribution
install_dependencies() {
    local distro=$1
    echo "Detected distribution: $distro"
    
    case $distro in
        debian)
            echo "Installing dependencies for Debian/Ubuntu..."
            sudo apt update
            sudo apt install -y cmake extra-cmake-modules plasma-framework-dev libkf5notifications-dev qt6-base-dev qt6-declarative-dev qt6-mqtt-dev mosquitto mosquitto-clients
            ;;
        fedora)
            echo "Installing dependencies for Fedora/RHEL/CentOS..."
            sudo dnf install -y cmake gcc-c++ extra-cmake-modules kf5-plasma-devel kf5-knotifications-devel qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmqtt-devel mosquitto mosquitto-clients
            ;;
        arch)
            echo "Installing dependencies for Arch Linux/Manjaro..."
            sudo pacman -S --needed --noconfirm cmake extra-cmake-modules plasma-framework qt6-base qt6-declarative knotifications qt6-mqtt mosquitto
            ;;
        *)
            echo "Unknown distribution. Please install dependencies manually:"
            echo "  - Debian/Ubuntu: sudo apt install cmake extra-cmake-modules plasma-framework-dev libkf5notifications-dev qt6-base-dev qt6-declarative-dev qt6-mqtt-dev mosquitto mosquitto-clients"
            echo "  - Fedora: sudo dnf install cmake gcc-c++ extra-cmake-modules kf5-plasma-devel kf5-knotifications-devel qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmqtt-devel mosquitto mosquitto-clients"
            echo "  - Arch Linux: sudo pacman -S cmake extra-cmake-modules plasma-framework qt6-base qt6-declarative knotifications qt6-mqtt mosquitto"
            
            read -p "Continue with installation anyway? (y/n) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# Check if plasmapkg6 or plasmapkg2 is available
check_plasmapkg() {
    if command -v plasmapkg6 &> /dev/null; then
        PLASMAPKG_CMD="plasmapkg6"
    elif command -v plasmapkg2 &> /dev/null; then
        PLASMAPKG_CMD="plasmapkg2"
    else
        echo "Error: Neither plasmapkg6 nor plasmapkg2 command found."
        
        # Attempt to install plasma-framework based on distribution
        local distro=$(detect_distro)
        case $distro in
            debian)
                echo "Attempting to install plasma-framework..."
                sudo apt update && sudo apt install -y plasma-framework
                ;;
            fedora)
                echo "Attempting to install plasma-framework..."
                sudo dnf install -y kf5-plasma-devel
                ;;
            arch)
                echo "Attempting to install plasma-framework..."
                sudo pacman -S --needed --noconfirm plasma-framework
                ;;
            *)
                echo "Please install the plasma framework package for your distribution:"
                echo "  - Debian/Ubuntu: sudo apt install plasma-framework"
                echo "  - Fedora: sudo dnf install kf5-plasma-devel"
                echo "  - Arch Linux: sudo pacman -S plasma-framework"
                exit 1
                ;;
        esac
        
        # Check again after installation attempt
        if command -v plasmapkg6 &> /dev/null; then
            PLASMAPKG_CMD="plasmapkg6"
        elif command -v plasmapkg2 &> /dev/null; then
            PLASMAPKG_CMD="plasmapkg2"
        else
            echo "Error: Failed to install plasma-framework. Please install it manually."
            exit 1
        fi
    fi
    
    echo "Using $PLASMAPKG_CMD for installation"
}

# Check if mosquitto_pub is installed
check_mosquitto() {
    if ! command -v mosquitto_pub &> /dev/null; then
        echo "Mosquitto clients not found. Installing..."
        
        local distro=$(detect_distro)
        case $distro in
            debian)
                sudo apt update && sudo apt install -y mosquitto-clients
                ;;
            fedora)
                sudo dnf install -y mosquitto
                ;;
            arch)
                sudo pacman -S --needed --noconfirm mosquitto
                ;;
            *)
                echo "Warning: Could not install mosquitto-clients automatically."
                echo "You may need to install it manually for testing."
                ;;
        esac
    else
        echo "Mosquitto clients already installed."
    fi
}

# Check if Qt MQTT module is installed
check_qt_mqtt() {
    echo "Checking for Qt MQTT module..."
    if ! qmlscene -I /usr/lib/qt/qml -e "import QtMqtt 6.2; console.log('Qt MQTT module found')" &> /dev/null; then
        echo "Qt MQTT module not found. Installing..."
        
        local distro=$(detect_distro)
        case $distro in
            debian)
                sudo apt update && sudo apt install -y qt6-mqtt-dev
                ;;
            fedora)
                sudo dnf install -y qt6-qtmqtt-devel
                ;;
            arch)
                sudo pacman -S --needed --noconfirm qt6-mqtt
                ;;
            *)
                echo "Warning: Could not install Qt MQTT module automatically."
                echo "Please install the Qt MQTT module for your distribution:"
                echo "  - Debian/Ubuntu: sudo apt install qt6-mqtt-dev"
                echo "  - Fedora: sudo dnf install qt6-qtmqtt-devel"
                echo "  - Arch Linux: sudo pacman -S qt6-mqtt"
                
                read -p "Continue with installation anyway? (y/n) " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
        esac
        
        # Check again after installation attempt
        if ! qmlscene -I /usr/lib/qt/qml -e "import QtMqtt 6.2; console.log('Qt MQTT module found')" &> /dev/null; then
            echo "Warning: Qt MQTT module installation may have failed."
            read -p "Continue with installation anyway? (y/n) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            echo "Qt MQTT module successfully installed."
        fi
    else
        echo "Qt MQTT module already installed."
    fi
}

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

# Detect distribution and install dependencies if needed
DISTRO=$(detect_distro)
if [ "$DISTRO" != "unknown" ]; then
    read -p "Do you want to check and install missing dependencies? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dependencies "$DISTRO"
    fi
fi

# Check for required components
check_plasmapkg
check_qt_mqtt
check_mosquitto

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