#ifndef VIDEORECORDER_H
#define VIDEORECORDER_H

#include <QObject>
#include <QImage>

extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

class VideoRecorder : public QObject
{
    Q_OBJECT

public:
    explicit VideoRecorder(QObject *parent = nullptr);
    ~VideoRecorder();

    Q_INVOKABLE bool startRecording(const QString &filename, int width, int height, int fps = 30);
    Q_INVOKABLE void addFrame(const QImage &image);
    Q_INVOKABLE void stopRecording();

private:
    void initEncoder();
    void closeEncoder();

    QString m_filename;
    int m_width = 0, m_height = 0, m_fps = 30;
    bool m_recording = false;

    AVFormatContext *m_formatCtx = nullptr;
    AVCodecContext *m_codecCtx = nullptr;
    AVStream *m_stream = nullptr;
    SwsContext *m_swsCtx = nullptr;
    AVFrame *m_yuvFrame = nullptr;
    uint8_t *m_yuvBuffer = nullptr;
    int64_t m_frameCounter = 0;
};

#endif // VIDEORECORDER_H
