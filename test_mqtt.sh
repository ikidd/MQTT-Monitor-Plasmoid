#!/bin/bash

# MQTT Monitor Test Script
# This script sends test MQTT messages to help test the plasmoid

# Default values
BROKER="localhost"
PORT="1883"
USERNAME=""
PASSWORD=""

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --host HOSTNAME    MQTT broker hostname (default: localhost)"
    echo "  -p, --port PORT        MQTT broker port (default: 1883)"
    echo "  -u, --username USER    MQTT username (if required)"
    echo "  -P, --password PASS    MQTT password (if required)"
    echo "  --help                 Display this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--host)
            BROKER="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -P|--password)
            PASSWORD="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if mosquitto_pub is installed
if ! command -v mosquitto_pub &> /dev/null; then
    echo "Error: mosquitto_pub command not found."
    echo "Please install the Mosquitto clients package for your distribution:"
    echo "  - Debian/Ubuntu: sudo apt install mosquitto-clients"
    echo "  - Fedora: sudo dnf install mosquitto"
    echo "  - Arch Linux: sudo pacman -S mosquitto"
    exit 1
fi

# Build auth parameters if provided
AUTH_PARAMS=""
if [ ! -z "$USERNAME" ]; then
    AUTH_PARAMS="-u $USERNAME"
    if [ ! -z "$PASSWORD" ]; then
        AUTH_PARAMS="$AUTH_PARAMS -P $PASSWORD"
    fi
fi

# Function to publish a message
publish() {
    local topic=$1
    local message=$2
    echo "Publishing to $topic: $message"
    
    mosquitto_pub -h "$BROKER" -p "$PORT" $AUTH_PARAMS -t "$topic" -m "$message"
    
    if [ $? -eq 0 ]; then
        echo "✓ Message sent successfully"
    else
        echo "✗ Failed to send message"
    fi
    echo ""
}

echo "=== MQTT Monitor Test Script ==="
echo "Broker: $BROKER:$PORT"
if [ ! -z "$USERNAME" ]; then
    echo "Username: $USERNAME"
fi
echo ""

# Menu loop
while true; do
    echo "Select a test message to send:"
    echo "1) Temperature above threshold (32°C)"
    echo "2) Temperature below threshold (15°C)"
    echo "3) Temperature at threshold (30°C)"
    echo "4) Door opened"
    echo "5) Door closed"
    echo "6) Custom message"
    echo "7) Exit"
    echo ""
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            publish "home/sensors/temperature" "32"
            ;;
        2)
            publish "home/sensors/temperature" "15"
            ;;
        3)
            publish "home/sensors/temperature" "30"
            ;;
        4)
            publish "home/sensors/door" "open"
            ;;
        5)
            publish "home/sensors/door" "closed"
            ;;
        6)
            read -p "Enter topic: " custom_topic
            read -p "Enter message: " custom_message
            publish "$custom_topic" "$custom_message"
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done