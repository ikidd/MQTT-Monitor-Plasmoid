# Project Synopsis: MQTT Monitor KDE Plasmoid

## Overview

This project is a KDE Plasma Plasmoid (`org.kde.plasma.mqttmonitor`) that connects to an MQTT broker, subscribes to specified topics, and displays desktop notifications when received messages match user-defined conditions. It is built using QML and targets KDE Plasma 6, with compatibility for Plasma 5 mentioned in the README.

## Project Structure

*   `README.md`: Provides an overview, features, requirements, installation instructions (script, `plasmapkg`, manual), testing steps, troubleshooting tips, and license information.
*   `install.sh`: A bash script that detects the Linux distribution (Debian/Ubuntu, Fedora, Arch), optionally installs dependencies (build tools, Plasma dev, Qt6, Qt6-MQTT, Mosquitto), checks for required commands (`plasmapkg`, `qmlscene`), and installs/updates the plasmoid using `plasmapkg6` or `plasmapkg2`.
*   `test_mqtt.sh`: A bash script using `mosquitto_pub` to send test MQTT messages (predefined or custom) to a specified broker for testing the plasmoid's functionality.
*   `org.kde.plasma.mqttmonitor/`: The main directory containing the plasmoid code.
    *   `metadata.json`: Plasma 6 metadata file defining the applet's ID, name ("MQTT Monitor"), description, category, icon, version, author, license, and main QML script (`contents/ui/main.qml`).
    *   `contents/`: Standard directory for plasmoid content.
        *   `config/`: Configuration files.
            *   `main.xml`: KConfigXT schema defining configuration keys (`serverAddress`, `serverPort`, `username`, `password`, `autoConnect`, `topics`, `conditions`), their types, and default values.
            *   `config.qml`: Defines the structure of the configuration dialog, loading `ConfigGeneral.qml`.
        *   `ui/`: User interface files.
            *   `main.qml`: The core application logic and main UI. It handles MQTT connection (`QtMqtt.MqttClient`), topic subscription, message reception, condition checking, notification triggering (`org.kde.notification.Notification`), and displays status/messages.
            *   `config/ConfigGeneral.qml`: Implements the configuration UI using Kirigami components, providing fields linked to the KConfigXT keys defined in `main.xml`.

## Core Functionality

1.  **MQTT Connection:** Establishes a connection to an MQTT broker using settings (address, port, username, password) stored via KConfigXT and configured through the UI. Supports auto-connect on startup.
2.  **Topic Subscription:** Subscribes to a comma-separated list of topics defined in the configuration.
3.  **Message Handling:** Receives messages via the `QtMqtt.MqttClient`. Displays the last 10 messages (topic and payload) in the plasmoid UI.
4.  **Condition Engine:** Parses conditions defined in the configuration (format: `topic|type|value|message`).
    *   Matches incoming messages based on the `topic`.
    *   Compares the payload based on `type` ("string" or "integer").
    *   Supports exact match for strings and comparison operators (>, <, =) for integers.
5.  **Notifications:** Uses `org.kde.notification.Notification` to send desktop notifications with a custom message when a condition is met.
6.  **Configuration UI:** Provides a settings dialog (`ConfigGeneral.qml`) to modify connection parameters, subscribed topics, and notification conditions.

## Dependencies

*   KDE Plasma (5.15+ or 6.x)
*   Qt (6.2+)
*   Qt MQTT Module (`qt6-mqtt`)
*   CMake & Extra CMake Modules
*   Plasma Framework (`plasma-framework`)
*   KNotifications (`knotifications`)
*   Mosquitto (optional, for testing)

## Build/Installation

*   Primarily via the `install.sh` script which handles dependencies and uses `plasmapkg`.
*   Manual installation via `plasmapkg` or copying files is also possible (detailed in README).