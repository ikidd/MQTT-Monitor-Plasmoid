import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import org.kde.kirigami 6.0 as Kirigami
import org.kde.plasma.core 6.0 as PlasmaCore

Item {
    id: root
    
    property alias cfg_serverAddress: serverAddressField.text
    property alias cfg_serverPort: serverPortField.value
    property alias cfg_username: usernameField.text
    property alias cfg_password: passwordField.text
    property alias cfg_autoConnect: autoConnectCheckbox.checked
    property alias cfg_topics: topicsField.text
    property alias cfg_conditions: conditionsField.text
    
    Kirigami.FormLayout {
        anchors.fill: parent
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("MQTT Server Settings")
        }
        
        TextField {
            id: serverAddressField
            Kirigami.FormData.label: i18n("Server Address:")
            placeholderText: "localhost"
        }
        
        SpinBox {
            id: serverPortField
            Kirigami.FormData.label: i18n("Server Port:")
            from: 1
            to: 65535
            value: 1883
        }
        
        TextField {
            id: usernameField
            Kirigami.FormData.label: i18n("Username (optional):")
            placeholderText: i18n("Leave empty for no authentication")
        }
        
        TextField {
            id: passwordField
            Kirigami.FormData.label: i18n("Password (optional):")
            placeholderText: i18n("Leave empty for no authentication")
            echoMode: TextInput.Password
        }
        
        CheckBox {
            id: autoConnectCheckbox
            Kirigami.FormData.label: i18n("Auto Connect:")
            text: i18n("Connect automatically on startup")
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Topic Settings")
        }
        
        TextArea {
            id: topicsField
            Kirigami.FormData.label: i18n("Topics to Subscribe (comma separated):")
            placeholderText: "home/sensors/#, office/temperature"
            Layout.fillWidth: true
            Layout.minimumHeight: 60
        }
        
        Label {
            text: i18n("Notification Conditions:")
            Layout.fillWidth: true
        }
        
        TextArea {
            id: conditionsField
            Layout.fillWidth: true
            Layout.minimumHeight: 120
            placeholderText: i18n("Format: topic|type|value|message\nExample: home/sensors/temperature|integer|>30|Temperature is too high!\nExample: home/sensors/door|string|open|Door has been opened!")
        }
        
        Label {
            text: i18n("Condition format: topic|type|value|message\nType can be 'string' or 'integer'\nFor integers, you can use >, <, or = before the value")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}