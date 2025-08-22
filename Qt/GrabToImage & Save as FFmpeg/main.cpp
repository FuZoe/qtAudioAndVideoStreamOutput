#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "videorecorder.h"
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    VideoRecorder recorder;
    engine.rootContext()->setContextProperty("videoRecorder", &recorder);

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

    //engine.loadFromModule("FFmpegDemo", "Main");
    engine.load(url);

    return app.exec();
}
