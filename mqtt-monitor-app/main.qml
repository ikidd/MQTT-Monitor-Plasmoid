import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2
import QtQuick.Window 6.2
import QtMqtt 6.2

Window {
    id: root
    width: 500
    height: 600
    visible: true
    title: "MQTT Monitor"
    
    property string serverAddress: "localhost"
    property int serverPort: 1883
    property string username: ""
    property string password: ""
    property bool autoConnect: false
    property string topics: "home/sensors/#"
    property string conditions: "home/sensors/temperature|integer|>30|Temperature is too high!\nhome/sensors/door|string|open|Door has been opened!"
    
    // Load settings from config file if it exists
    Component.onCompleted: {
        loadSettings()
        
        // Try to connect if auto-connect is enabled
        if (autoConnect) {
            mqttClient.connectToHost()
        }
    }
    
    // MQTT client
    MqttClient {
        id: mqttClient
        hostname: root.serverAddress
        port: root.serverPort
        username: root.username
        password: root.password
        clientId: "mqtt_monitor_" + Math.random().toString(36).substring(2, 10)
        
        onConnected: {
            statusText.text = "Connected"
            statusText.color = "green"
            
            // Subscribe to configured topics
            var topicsList = root.topics.split(',')
            for (var i = 0; i < topicsList.length; i++) {
                var topic = topicsList[i].trim()
                if (topic) {
                    mqttClient.subscribe(topic)
                    console.log("Subscribed to: " + topic)
                }
            }
        }
        
        onErrorChanged: {
            statusText.text = "Error: " + error
            statusText.color = "red"
        }
        
        onMessageReceived: {
            var payload = message.payload.toString()
            console.log("Message received on topic: " + message.topic + ", payload: " + payload)
            
            // Check conditions for notifications
            checkNotificationConditions(message.topic, payload)
        }
    }
    
    function checkNotificationConditions(topic, payload) {
        var conditionsList = root.conditions.split('\n')
        
        for (var i = 0; i < conditionsList.length; i++) {
            var condition = conditionsList[i].trim()
            if (!condition) continue
            
            var parts = condition.split('|')
            if (parts.length < 3) continue
            
            var conditionTopic = parts[0].trim()
            var conditionType = parts[1].trim()
            var conditionValue = parts[2].trim()
            var conditionMessage = parts.length > 3 ? parts[3].trim() : "Condition met for topic " + topic
            
            // Check if this condition applies to the current topic
            if (topic === conditionTopic) {
                var shouldNotify = false
                
                if (conditionType === "string") {
                    shouldNotify = (payload === conditionValue)
                } else if (conditionType === "integer") {
                    var payloadNum = parseInt(payload)
                    var conditionNum = parseInt(conditionValue)
                    
                    if (!isNaN(payloadNum) && !isNaN(conditionNum)) {
                        // Check if the condition has an operator
                        if (conditionValue.startsWith(">")) {
                            conditionNum = parseInt(conditionValue.substring(1))
                            shouldNotify = payloadNum > conditionNum
                        } else if (conditionValue.startsWith("<")) {
                            conditionNum = parseInt(conditionValue.substring(1))
                            shouldNotify = payloadNum < conditionNum
                        } else if (conditionValue.startsWith("=")) {
                            conditionNum = parseInt(conditionValue.substring(1))
                            shouldNotify = payloadNum === conditionNum
                        } else {
                            shouldNotify = payloadNum === conditionNum
                        }
                    }
                }
                
                if (shouldNotify) {
                    showNotification("MQTT Monitor", conditionMessage)
                }
            }
        }
    }
    
    // Simple notification function for desktop app
    function showNotification(title, message) {
        notificationPopup.title = title
        notificationPopup.text = message
        notificationPopup.open()
    }
    
    // Save settings to a config file
    function saveSettings() {
        var settings = {
            "serverAddress": root.serverAddress,
            "serverPort": root.serverPort,
            "username": root.username,
            "password": root.password,
            "autoConnect": root.autoConnect,
            "topics": root.topics,
            "conditions": root.conditions
        }
        
        settingsStorage.setValue("settings", JSON.stringify(settings))
    }
    
    // Load settings from config file
    function loadSettings() {
        var settingsStr = settingsStorage.value("settings")
        if (settingsStr) {
            try {
                var settings = JSON.parse(settingsStr)
                root.serverAddress = settings.serverAddress || "localhost"
                root.serverPort = settings.serverPort || 1883
                root.username = settings.username || ""
                root.password = settings.password || ""
                root.autoConnect = settings.autoConnect || false
                root.topics = settings.topics || "home/sensors/#"
                root.conditions = settings.conditions || "home/sensors/temperature|integer|>30|Temperature is too high!\nhome/sensors/door|string|open|Door has been opened!"
            } catch (e) {
                console.error("Error loading settings:", e)
            }
        }
    }
    
    // Settings storage
    QtObject {
        id: settingsStorage
        
        function setValue(key, value) {
            settings.setValue(key, value)
        }
        
        function value(key) {
            return settings.value(key, "")
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        Label {
            id: statusText
            text: "Disconnected"
            color: "red"
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 12
            font.bold: true
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            Button {
                text: mqttClient.state === MqttClient.Connected ? "Disconnect" : "Connect"
                Layout.fillWidth: true
                onClicked: {
                    if (mqttClient.state === MqttClient.Connected) {
                        mqttClient.disconnectFromHost()
                        statusText.text = "Disconnected"
                        statusText.color = "red"
                    } else {
                        mqttClient.connectToHost()
                    }
                }
            }
            
            Button {
                text: "Settings"
                Layout.fillWidth: true
                onClicked: {
                    settingsDialog.open()
                }
            }
        }
        
        GroupBox {
            title: "Messages"
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: messageList
                anchors.fill: parent
                model: ListModel { id: messagesModel }
                clip: true
                
                delegate: ItemDelegate {
                    width: messageList.width
                    height: messageText.height + 20
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 2
                        
                        Label {
                            text: topic
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        Label {
                            id: messageText
                            text: payload
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
                
                Component.onCompleted: {
                    // Connect to message received signal
                    mqttClient.messageReceived.connect(function(message) {
                        var payload = message.payload.toString()
                        messagesModel.insert(0, { topic: message.topic, payload: payload })
                        
                        // Limit the number of displayed messages
                        if (messagesModel.count > 50) {
                            messagesModel.remove(50, messagesModel.count - 50)
                        }
                    })
                }
            }
        }
    }
    
    // Settings Dialog
    Dialog {
        id: settingsDialog
        title: "MQTT Monitor Settings"
        width: 500
        height: 600
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        
        onAccepted: {
            // Apply settings
            root.serverAddress = serverAddressField.text
            root.serverPort = serverPortField.value
            root.username = usernameField.text
            root.password = passwordField.text
            root.autoConnect = autoConnectCheckbox.checked
            root.topics = topicsField.text
            root.conditions = conditionsField.text
            
            // Save settings
            saveSettings()
            
            // If connected, disconnect and reconnect to apply new settings
            if (mqttClient.state === MqttClient.Connected) {
                mqttClient.disconnectFromHost()
                if (root.autoConnect) {
                    mqttClient.connectToHost()
                }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            GroupBox {
                title: "Server Settings"
                Layout.fillWidth: true
                
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    
                    Label { text: "Server Address:" }
                    TextField {
                        id: serverAddressField
                        text: root.serverAddress
                        Layout.fillWidth: true
                        placeholderText: "localhost"
                    }
                    
                    Label { text: "Server Port:" }
                    SpinBox {
                        id: serverPortField
                        from: 1
                        to: 65535
                        value: root.serverPort
                        Layout.fillWidth: true
                    }
                    
                    Label { text: "Username:" }
                    TextField {
                        id: usernameField
                        text: root.username
                        Layout.fillWidth: true
                        placeholderText: "Optional"
                    }
                    
                    Label { text: "Password:" }
                    TextField {
                        id: passwordField
                        text: root.password
                        Layout.fillWidth: true
                        placeholderText: "Optional"
                        echoMode: TextInput.Password
                    }
                    
                    Label { text: "Auto Connect:" }
                    CheckBox {
                        id: autoConnectCheckbox
                        checked: root.autoConnect
                    }
                }
            }
            
            GroupBox {
                title: "Topics"
                Layout.fillWidth: true
                
                ColumnLayout {
                    width: parent.width
                    
                    Label { text: "Topics to Subscribe (comma separated):" }
                    TextArea {
                        id: topicsField
                        text: root.topics
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        placeholderText: "home/sensors/#, office/temperature"
                    }
                }
            }
            
            GroupBox {
                title: "Notification Conditions"
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                ColumnLayout {
                    width: parent.width
                    
                    Label { 
                        text: "Format: topic|type|value|message\nType can be 'string' or 'integer'\nFor integers, you can use >, <, or = before the value"
                        wrapMode: Text.WordWrap
                    }
                    
                    TextArea {
                        id: conditionsField
                        text: root.conditions
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "home/sensors/temperature|integer|>30|Temperature is too high!\nhome/sensors/door|string|open|Door has been opened!"
                    }
                }
            }
        }
    }
    
    // Notification popup
    Popup {
        id: notificationPopup
        width: 300
        height: 100
        x: parent.width - width - 20
        y: 20
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property string title: ""
        property string text: ""
        
        background: Rectangle {
            color: "#f0f0f0"
            border.color: "#cccccc"
            border.width: 1
            radius: 5
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            
            Label {
                text: notificationPopup.title
                font.bold: true
                font.pointSize: 12
                Layout.fillWidth: true
            }
            
            Label {
                text: notificationPopup.text
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
        
        Timer {
            running: notificationPopup.visible
            interval: 5000
            onTriggered: notificationPopup.close()
        }
    }
}