#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "GstStreamer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    GstStreamer streamer;
    engine.rootContext()->setContextProperty("gstStreamer", &streamer);
    const QUrl url(QStringLiteral("qrc:/GrabToImage/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
