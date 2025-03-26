# MQTT Monitor KDE Plasmoid - Fedora Installation Guide

This guide provides detailed instructions for installing and testing the MQTT Monitor KDE Plasmoid on Fedora-based systems.

## Installation

> **Note:** This plasmoid supports both Plasma 5 and Plasma 6. For Plasma 6, it uses the new metadata.json format, while for Plasma 5 it uses the traditional metadata.desktop format.

### 1. Install Dependencies

First, install all the required dependencies:

```bash
# Install development tools
sudo dnf install cmake gcc-c++ extra-cmake-modules

# Install KDE development packages
sudo dnf install kf5-plasma-devel kf5-knotifications-devel

# Install Qt dependencies
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# Install MQTT dependencies
sudo dnf install qt6-qtmqtt-devel

# Install Mosquitto for testing (optional)
sudo dnf install mosquitto mosquitto-clients
```

### 2. Install the Plasmoid

#### Method 1: Using the installation script

```bash
# Make the script executable (if not already)
chmod +x install.sh

# Run the installation script
./install.sh
```

#### Method 2: Manual installation using plasmapkg

```bash
# Install the plasmoid (use plasmapkg6 for Qt6 systems, plasmapkg2 for older systems)
plasmapkg6 -i org.kde.plasma.mqttmonitor || plasmapkg2 -i org.kde.plasma.mqttmonitor
```

#### Method 3: Manual installation by copying files

```bash
# Create the destination directory if it doesn't exist
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.mqttmonitor

# Copy the plasmoid files
cp -r org.kde.plasma.mqttmonitor/* ~/.local/share/plasma/plasmoids/org.kde.plasma.mqttmonitor/
```

### 3. Restart Plasma Shell

After installation, restart the Plasma shell to ensure the widget is properly loaded:

```bash
kquitapp6 plasmashell || kquitapp5 plasmashell
kstart6 plasmashell || kstart5 plasmashell
```

## Setting Up MQTT Broker for Testing

For testing purposes, you can use the built-in Mosquitto MQTT broker:

### 1. Start the Mosquitto service

```bash
# Start the service
sudo systemctl start mosquitto

# Enable it to start on boot (optional)
sudo systemctl enable mosquitto

# Check if it's running
sudo systemctl status mosquitto
```

### 2. Configure Mosquitto (Optional)

By default, Mosquitto allows anonymous connections on localhost. If you want to customize it:

```bash
# Create a configuration file
sudo nano /etc/mosquitto/conf.d/local.conf
```

Add the following content for a basic configuration:

```
listener 1883
allow_anonymous true
```

Then restart Mosquitto:

```bash
sudo systemctl restart mosquitto
```

## Adding the Plasmoid to Your Desktop

1. Right-click on your desktop or panel
2. Select "Add Widgets..."
3. Search for "MQTT Monitor"
4. Drag it to your desktop or panel

## Configuring the Plasmoid

1. Right-click on the plasmoid and select "Configure..."
2. Enter your MQTT server details:
   - Server Address: `localhost` (if using local Mosquitto)
   - Port: `1883` (default MQTT port)
   - Username/Password: Leave empty for anonymous local connections
   - Topics: `test/#` (subscribes to all topics starting with "test/")
   - Add notification conditions (e.g., `test/temperature|integer|>30|Temperature is too high!`)

## Testing the Plasmoid

### Method 1: Using the provided test script

```bash
# Make the script executable (if not already)
chmod +x test_mqtt.sh

# Run the test script
./test_mqtt.sh
```

### Method 2: Manual testing with mosquitto_pub

```bash
# Test with a temperature value
mosquitto_pub -h localhost -t "test/temperature" -m "32"

# Test with a string value
mosquitto_pub -h localhost -t "test/door" -m "open"
```

## Troubleshooting

### Common Issues on Fedora

1. **Missing Qt MQTT module**
   
   If you get errors about missing Qt MQTT module:
   ```bash
   sudo dnf install qt6-qtmqtt qt6-qtmqtt-devel
   ```

2. **SELinux Blocking Connections**
   
   If you have connection issues, it might be SELinux:
   ```bash
   # Check if SELinux is blocking connections
   sudo ausearch -m avc -ts recent
   
   # Temporarily set SELinux to permissive mode for testing
   sudo setenforce 0
   
   # To make a permanent exception for Mosquitto
   sudo setsebool -P nis_enabled 1
   ```

3. **Firewall Issues**
   
   Make sure the MQTT port is open:
   ```bash
   sudo firewall-cmd --permanent --add-port=1883/tcp
   sudo firewall-cmd --reload
   ```

4. **Plasmoid Not Appearing**
   
   Clear the KDE cache:
   ```bash
   rm -rf ~/.cache/plasma*
   kquitapp6 plasmashell || kquitapp5 plasmashell
   kstart6 plasmashell || kstart5 plasmashell
   ```

## Uninstalling

If you need to remove the plasmoid:

```bash
plasmapkg6 -r org.kde.plasma.mqttmonitor || plasmapkg2 -r org.kde.plasma.mqttmonitor
```

## Additional Resources

- [Fedora KDE Documentation](https://docs.fedoraproject.org/en-US/fedora/latest/getting-started/desktop/kde/)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [KDE Plasma Development Documentation](https://develop.kde.org/docs/plasma/)