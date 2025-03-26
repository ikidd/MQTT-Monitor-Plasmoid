# MQTT Monitor KDE Plasmoid

A KDE Plasma widget that allows you to connect to an MQTT server, subscribe to topics, and receive notifications based on configurable conditions.

## Features

- Connect to any MQTT broker
- Subscribe to multiple topics
- Configure notification conditions for string or integer values
- Support for comparison operators (>, <, =) for integer values
- Desktop notifications when conditions are met

## Requirements

- KDE Plasma 5.15 or newer (Plasma 6.x fully supported)
- Qt 6.2 or newer
- Qt MQTT module

> **Note:** This plasmoid supports both Plasma 5 and Plasma 6. For Plasma 6, it uses the new metadata.json format, while for Plasma 5 it uses the traditional metadata.desktop format.

## Installation

### Install Dependencies

First, make sure you have the required dependencies:

#### For Debian/Ubuntu-based distributions

```bash
# Install development tools
sudo apt install cmake extra-cmake-modules

# Install KDE development packages
sudo apt install plasma-framework-dev libkf5notifications-dev

# Install Qt dependencies
sudo apt install qt6-base-dev qt6-declarative-dev

# Install MQTT dependencies
sudo apt install qt6-mqtt-dev

# Install Mosquitto for testing (optional)
sudo apt install mosquitto mosquitto-clients
```

#### For Fedora-based distributions

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

#### For Arch Linux

```bash
sudo pacman -S cmake extra-cmake-modules plasma-framework qt6-base qt6-declarative knotifications qt6-mqtt mosquitto
```

### Install the Plasmoid

#### Method 1: Using the installation script

```bash
# Make the script executable (if not already)
chmod +x install.sh

# Run the installation script
./install.sh
```

#### Method 2: Using plasmapkg

```bash
# Navigate to the directory containing the plasmoid
cd /path/to/MQTT\ Plasmoid/

# Install the plasmoid (use plasmapkg6 for Qt6 systems, plasmapkg2 for older systems)
plasmapkg6 -i org.kde.plasma.mqttmonitor || plasmapkg2 -i org.kde.plasma.mqttmonitor
```

#### Method 3: Manual installation

```bash
# Create the destination directory if it doesn't exist
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.mqttmonitor

# Copy the plasmoid files
cp -r org.kde.plasma.mqttmonitor/* ~/.local/share/plasma/plasmoids/org.kde.plasma.mqttmonitor/
```

After installation, you may need to restart Plasma:

```bash
kquitapp6 plasmashell || kquitapp5 plasmashell
kstart6 plasmashell || kstart5 plasmashell
```

## Setting Up MQTT Broker for Testing

For testing purposes, you can use the built-in Mosquitto MQTT broker:

### 1. Start the Mosquitto service

```bash
# For systemd-based distributions (Ubuntu, Fedora, etc.)
sudo systemctl start mosquitto
sudo systemctl enable mosquitto  # Optional: start on boot
sudo systemctl status mosquitto  # Check if it's running

# For non-systemd distributions
sudo service mosquitto start
```

### 2. Configure Mosquitto (Optional)

By default, Mosquitto allows anonymous connections on localhost. If you want to customize it:

```bash
# Create a configuration file
sudo nano /etc/mosquitto/conf.d/local.conf  # Fedora/Ubuntu
# or
sudo nano /etc/mosquitto/mosquitto.conf     # Some distributions
```

Add the following content for a basic configuration:

```
listener 1883
allow_anonymous true
```

Then restart Mosquitto:

```bash
sudo systemctl restart mosquitto  # For systemd
# or
sudo service mosquitto restart    # For non-systemd
```

## Usage

1. Right-click on your desktop or panel and select "Add Widgets"
2. Search for "MQTT Monitor" and add it to your desktop or panel
3. Right-click on the widget and select "Configure..."
4. Enter your MQTT server details:
   - Server address (e.g., localhost, broker.hivemq.com)
   - Port (default: 1883)
   - Username and password (if required)
   - Topics to subscribe to (comma-separated)
   - Notification conditions

### Configuring Notification Conditions

Conditions are specified in the format: `topic|type|value|message`

- `topic`: The MQTT topic to monitor
- `type`: Either "string" or "integer"
- `value`: The value to compare against
  - For strings: exact match
  - For integers: can use >, <, or = operators (e.g., >30, <10, =5)
- `message`: The notification message to display when the condition is met

Examples:
```
home/sensors/temperature|integer|>30|Temperature is too high!
home/sensors/door|string|open|Door has been opened!
office/lights|integer|=1|Office lights are on
```

## Testing

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

### Common Issues

1. **Connection Issues**
   - Check if the MQTT broker is running and accessible
   - Verify your connection settings (address, port, credentials)
   - Check the Plasma logs for errors:
     ```bash
     journalctl -f -t plasmashell
     ```

2. **Missing Qt MQTT module**
   - For Debian/Ubuntu:
     ```bash
     sudo apt install qt6-mqtt-dev
     ```
   - For Fedora:
     ```bash
     sudo dnf install qt6-qtmqtt qt6-qtmqtt-devel
     ```

3. **SELinux Blocking Connections (Fedora)**
   ```bash
   # Check if SELinux is blocking connections
   sudo ausearch -m avc -ts recent
   
   # Temporarily set SELinux to permissive mode for testing
   sudo setenforce 0
   
   # To make a permanent exception for Mosquitto
   sudo setsebool -P nis_enabled 1
   ```

4. **Firewall Issues**
   - For Ubuntu:
     ```bash
     sudo ufw allow 1883/tcp
     ```
   - For Fedora:
     ```bash
     sudo firewall-cmd --permanent --add-port=1883/tcp
     sudo firewall-cmd --reload
     ```

5. **Plasmoid Not Appearing**
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

- [KDE Plasma Development Documentation](https://develop.kde.org/docs/plasma/)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [MQTT Protocol Documentation](https://mqtt.org/documentation/)

## License

This plasmoid is licensed under the GPL-2.0+ license.