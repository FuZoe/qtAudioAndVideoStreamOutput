#pragma once

#include <QObject>
#include <QImage>
#include <QVideoFrame>

#include <gst/gst.h>
#include <gst/app/gstappsrc.h>

class GstStreamer : public QObject {
    Q_OBJECT
public:
    explicit GstStreamer(QObject *parent = nullptr);
    ~GstStreamer();

    Q_INVOKABLE bool start(const QString &host, int port, int width, int height, int fps);
    Q_INVOKABLE void stop();
    Q_INVOKABLE bool pushImage(const QImage &img);
    Q_INVOKABLE bool pushVideoFrame(const QVideoFrame &frame);

private:
    GstElement *pipeline_ = nullptr;
    GstElement *appsrc_ = nullptr;
    int width_ = 0;
    int height_ = 0;
    int fps_ = 0;
    bool running_ = false;
};
