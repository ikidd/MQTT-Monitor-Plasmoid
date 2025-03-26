# MQTT Monitor KDE Plasmoid

A KDE Plasma widget that allows you to connect to an MQTT server, subscribe to topics, and receive notifications based on configurable conditions.

## Features

- Connect to any MQTT broker
- Subscribe to multiple topics
- Configure notification conditions for string or integer values
- Support for comparison operators (>, <, =) for integer values
- Desktop notifications when conditions are met

## Requirements

- KDE Plasma 5.15 or newer
- Qt 5.15 or newer
- Qt MQTT module

## Installation

### Install Dependencies

First, make sure you have the required dependencies:

```bash
# For Debian/Ubuntu
sudo apt install cmake extra-cmake-modules plasma-framework-dev qtbase5-dev qtdeclarative5-dev libkf5notifications-dev qtmqtt5-dev

# For Fedora
sudo dnf install cmake extra-cmake-modules kf5-plasma-devel qt5-qtbase-devel qt5-qtdeclarative-devel kf5-knotifications-devel qt5-qtmqtt-devel

# For Arch Linux
sudo pacman -S cmake extra-cmake-modules plasma-framework qt5-base qt5-declarative knotifications qt5-mqtt
```

### Install the Plasmoid

Method 1: Using plasmapkg2 (recommended)

```bash
# Navigate to the directory containing the plasmoid
cd /path/to/MQTT\ Plasmoid/

# Install the plasmoid
plasmapkg2 -i org.kde.plasma.mqttmonitor
```

Method 2: Manual installation

```bash
# Copy the plasmoid to the local plasmoids directory
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r org.kde.plasma.mqttmonitor ~/.local/share/plasma/plasmoids/
```

After installation, you may need to restart Plasma:

```bash
kquitapp5 plasmashell && kstart5 plasmashell
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

To test the plasmoid, you can use the mosquitto_pub command-line tool:

```bash
# Install mosquitto clients
sudo apt install mosquitto-clients  # Debian/Ubuntu
sudo dnf install mosquitto         # Fedora
sudo pacman -S mosquitto          # Arch Linux

# Publish test messages
mosquitto_pub -h localhost -t "home/sensors/temperature" -m "32"
mosquitto_pub -h localhost -t "home/sensors/door" -m "open"
```

## Troubleshooting

If you encounter issues:

1. Check if the MQTT broker is running and accessible
2. Verify your connection settings (address, port, credentials)
3. Check the Plasma logs for errors:
   ```bash
   journalctl -f -t plasmashell
   ```
4. Make sure the Qt MQTT module is installed correctly

## License

This plasmoid is licensed under the GPL-2.0+ license.