#!/bin/bash

# MQTT Monitor Desktop App installer script

echo "Installing MQTT Monitor Desktop Application..."

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
            sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-mqtt-dev build-essential
            ;;
        fedora)
            echo "Installing dependencies for Fedora/RHEL/CentOS..."
            sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmqtt-devel gcc-c++
            ;;
        arch)
            echo "Installing dependencies for Arch Linux/Manjaro..."
            sudo pacman -S --needed --noconfirm qt6-base qt6-declarative qt6-mqtt base-devel
            ;;
        *)
            echo "Unknown distribution. Please install dependencies manually:"
            echo "  - Debian/Ubuntu: sudo apt install qt6-base-dev qt6-declarative-dev qt6-mqtt-dev build-essential"
            echo "  - Fedora: sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmqtt-devel gcc-c++"
            echo "  - Arch Linux: sudo pacman -S qt6-base qt6-declarative qt6-mqtt base-devel"
            
            read -p "Continue with installation anyway? (y/n) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# Check if Qt MQTT module is installed
check_qt_mqtt() {
    echo "Checking for Qt MQTT module..."
    if ! qmake6 -query QT_INSTALL_LIBS | grep -q "mqtt"; then
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
    else
        echo "Qt MQTT module already installed."
    fi
}

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
check_qt_mqtt

# Build the application
echo "Building MQTT Monitor application..."
mkdir -p build
cd build
qmake6 ../mqtt-monitor.pro
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "Build failed. Please check the error messages above."
    exit 1
fi

# Install the application
echo "Installing MQTT Monitor application..."
sudo make install

if [ $? -eq 0 ]; then
    echo "Installation successful!"
    echo ""
    echo "You can now launch MQTT Monitor from your application menu"
    echo "or by running 'mqtt-monitor' from the terminal."
    
    # Create a desktop shortcut
    echo "Creating desktop shortcut..."
    mkdir -p ~/Desktop
    cp /usr/share/applications/mqtt-monitor.desktop ~/Desktop/
    chmod +x ~/Desktop/mqtt-monitor.desktop
    
    echo "Desktop shortcut created."
else
    echo "Installation failed. Please check the error messages above."
fi