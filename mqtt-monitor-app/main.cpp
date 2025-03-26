#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQmlContext>

class SettingsManager : public QObject
{
    Q_OBJECT
public:
    explicit SettingsManager(QObject *parent = nullptr) : QObject(parent) {
        m_settings = new QSettings("MQTTMonitor", "MQTTMonitor", this);
    }

    Q_INVOKABLE QString value(const QString &key, const QString &defaultValue = QString()) {
        return m_settings->value(key, defaultValue).toString();
    }

    Q_INVOKABLE void setValue(const QString &key, const QString &value) {
        m_settings->setValue(key, value);
        m_settings->sync();
    }

private:
    QSettings *m_settings;
};

#include "main.moc"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("MQTT Monitor");
    app.setOrganizationName("MQTTMonitor");
    
    QQmlApplicationEngine engine;
    
    // Register the settings manager
    SettingsManager settingsManager;
    engine.rootContext()->setContextProperty("settings", &settingsManager);
    
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);
    
    return app.exec();
}