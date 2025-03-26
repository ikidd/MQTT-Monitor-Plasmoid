# MQTT Monitor Desktop Application

A simple Qt-based desktop application for monitoring MQTT topics and receiving notifications.

## Features

- Connect to any MQTT broker
- Subscribe to multiple topics
- View incoming messages in real-time
- Set up notification conditions based on message content
- Receive desktop notifications when conditions are met
- Persistent configuration

## Requirements

- Qt 6.2 or later
- Qt MQTT module
- C++11 compatible compiler

## Installation

### Using the installer script

1. Make the installer script executable:
   ```
   chmod +x install.sh
   ```

2. Run the installer script:
   ```
   ./install.sh
   ```

3. The script will:
   - Check and install required dependencies
   - Build the application
   - Install it to your system
   - Create a desktop shortcut

### Manual installation

1. Install the required dependencies:
   - Debian/Ubuntu: `sudo apt install qt6-base-dev qt6-declarative-dev qt6-mqtt-dev build-essential`
   - Fedora: `sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtmqtt-devel gcc-c++`
   - Arch Linux: `sudo pacman -S qt6-base qt6-declarative qt6-mqtt base-devel`

2. Build the application:
   ```
   mkdir build
   cd build
   qmake6 ../mqtt-monitor.pro
   make
   ```

3. Install the application:
   ```
   sudo make install
   ```

## Usage

1. Launch the application from your desktop environment or run `mqtt-monitor` from the terminal.

2. Configure the MQTT connection:
   - Click on "Settings"
   - Enter your MQTT broker details
   - Configure topics to subscribe to
   - Set up notification conditions
   - Click "OK" to save settings

3. Click "Connect" to connect to the MQTT broker.

4. The application will display incoming messages and show notifications when conditions are met.

## Notification Conditions

Notification conditions use the following format:
```
topic|type|value|message
```

Where:
- `topic`: The MQTT topic to match
- `type`: Either "string" or "integer"
- `value`: The value to compare against
  - For string type: exact match
  - For integer type: can use >, <, or = operators
- `message`: The notification message to display

Examples:
```
home/sensors/temperature|integer|>30|Temperature is too high!
home/sensors/door|string|open|Door has been opened!
```

## License

This application is licensed under the GPL-2.0+ license.