import QtQuick 6.2
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2
import org.kde.plasma.plasmoid 6.0
import org.kde.plasma.core 6.0 as PlasmaCore
import org.kde.plasma.components 6.0 as PlasmaComponents
import org.kde.notification 1.0
import QtMqtt 6.2

Item {
    id: root
    
    // MQTT client
    MqttClient {
        id: mqttClient
        hostname: plasmoid.configuration.serverAddress
        port: plasmoid.configuration.serverPort
        username: plasmoid.configuration.username
        password: plasmoid.configuration.password
        clientId: "kde_plasmoid_" + Math.random().toString(36).substring(2, 10)
        
        onConnected: {
            statusText.text = "Connected"
            statusText.color = PlasmaCore.Theme.positiveTextColor
            
            // Subscribe to configured topics
            var topicsList = plasmoid.configuration.topics.split(',')
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
            statusText.color = PlasmaCore.Theme.negativeTextColor
        }
        
        onMessageReceived: {
            var payload = message.payload.toString()
            console.log("Message received on topic: " + message.topic + ", payload: " + payload)
            
            // Check conditions for notifications
            checkNotificationConditions(message.topic, payload)
        }
    }
    
    function checkNotificationConditions(topic, payload) {
        var conditionsList = plasmoid.configuration.conditions.split('\n')
        
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
                    var notification = Qt.createQmlObject('import org.kde.notification 1.0; Notification {}', root)
                    notification.title = "MQTT Monitor"
                    notification.text = conditionMessage
                    notification.iconName = "network-connect"
                    notification.sendEvent()
                }
            }
        }
    }
    
    Plasmoid.fullRepresentation: ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        PlasmaComponents.Label {
            id: statusText
            text: "Disconnected"
            color: PlasmaCore.Theme.negativeTextColor
            Layout.alignment: Qt.AlignHCenter
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            PlasmaComponents.Button {
                text: mqttClient.state === MqttClient.Connected ? "Disconnect" : "Connect"
                onClicked: {
                    if (mqttClient.state === MqttClient.Connected) {
                        mqttClient.disconnectFromHost()
                        statusText.text = "Disconnected"
                        statusText.color = PlasmaCore.Theme.negativeTextColor
                    } else {
                        mqttClient.connectToHost()
                    }
                }
            }
            
            PlasmaComponents.Button {
                text: "Configure"
                onClicked: {
                    plasmoid.action("configure").trigger()
                }
            }
        }
        
        ListView {
            id: messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ListModel { id: messagesModel }
            delegate: Item {
                width: messageList.width
                height: messageText.height + 10
                
                PlasmaComponents.Label {
                    id: messageText
                    width: parent.width
                    text: topic + ": " + payload
                    wrapMode: Text.WordWrap
                }
            }
            
            Component.onCompleted: {
                // Connect to message received signal
                mqttClient.messageReceived.connect(function(message) {
                    var payload = message.payload.toString()
                    messagesModel.insert(0, { topic: message.topic, payload: payload })
                    
                    // Limit the number of displayed messages
                    if (messagesModel.count > 10) {
                        messagesModel.remove(10, messagesModel.count - 10)
                    }
                })
            }
        }
    }
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    Component.onCompleted: {
        // Try to connect if auto-connect is enabled
        if (plasmoid.configuration.autoConnect) {
            mqttClient.connectToHost()
        }
    }
}