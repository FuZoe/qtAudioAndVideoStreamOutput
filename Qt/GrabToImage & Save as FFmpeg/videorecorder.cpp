// videorecorder.cpp
#include "videorecorder.h"
#include <QDebug>

VideoRecorder::VideoRecorder(QObject *parent)
    : QObject(parent)
{
}

VideoRecorder::~VideoRecorder()
{
    // 如果正在录制，先停止
    if (m_recording) {
        stopRecording();
    }
}

bool VideoRecorder::startRecording(const QString &filename, int width, int height, int fps)
{
    if (m_recording) return false;

    m_filename = filename;
    m_width = width;
    m_height = height;
    m_fps = fps;
    m_recording = true;

    avformat_alloc_output_context2(&m_formatCtx, nullptr, nullptr, filename.toUtf8().constData());
    if (!m_formatCtx) {
        qWarning() << "无法创建输出上下文";
        return false;
    }



    const AVCodec *codec = avcodec_find_encoder(m_formatCtx->oformat->video_codec);
    if (!codec) {
        qWarning() << "未找到编码器";
        return false;
    }

    qInfo() << "调试开始";

    // 在 avformat_alloc_output_context2 后面添加
    // const AVCodec *codec = avcodec_find_encoder(AV_CODEC_ID_H264); // 明确指定 H.264
    // if (!codec) {
    //     qWarning() << "未找到 H.264 编码器";
    //     return false;
    // }

    m_codecCtx = avcodec_alloc_context3(codec);
    if (!m_codecCtx) {
        qWarning() << "m_codecCtx is empty!";
        return false;
    }
    m_codecCtx->width = m_width;
    m_codecCtx->height = m_height;
    // 使用默认像素格式让FFmpeg自动选择
    m_codecCtx->pix_fmt = AV_PIX_FMT_YUV420P;
    m_codecCtx->time_base = {1, m_fps};
    m_codecCtx->framerate = {m_fps, 1};
    m_codecCtx->bit_rate = 2000000;

    // 添加调试信息
    qInfo() <<"m_codecCtx->codec_id"<<m_codecCtx->codec_id;

    //添加H.264格式参数
    // m_codecCtx->gop_size = 15;           // GOP大小
    // m_codecCtx->max_b_frames = 1;        // 最大B帧数
    // m_codecCtx->profile = FF_PROFILE_H264_MAIN;  // H.264 Profile
    // m_codecCtx->level = 30;              // H.264 Level

    if (avcodec_open2(m_codecCtx, codec, nullptr) < 0) {
        qWarning() << "无法打开编码器";  //改为H.264的时候这里有提示，可能是m_codecCtx参数不对
        return false;
    }

    m_stream = avformat_new_stream(m_formatCtx, nullptr);
    avcodec_parameters_from_context(m_stream->codecpar, m_codecCtx);

    if (!(m_formatCtx->oformat->flags & AVFMT_NOFILE)) {
        if (avio_open(&m_formatCtx->pb, filename.toUtf8().constData(), AVIO_FLAG_WRITE) < 0) {
            qWarning() << "无法打开输出文件";
            return false;
        }
    }

    if (avformat_write_header(m_formatCtx, nullptr) < 0) {
        qWarning() << "无法写入文件头";
        return false;
    }

    m_yuvFrame = av_frame_alloc();
    m_yuvFrame->format = AV_PIX_FMT_YUV420P;
    m_yuvFrame->width = m_width;
    m_yuvFrame->height = m_height;
    int numBytes = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, m_width, m_height, 1);
    m_yuvBuffer = (uint8_t*)av_malloc(numBytes);
    av_image_fill_arrays(m_yuvFrame->data, m_yuvFrame->linesize, m_yuvBuffer, AV_PIX_FMT_YUV420P, m_width, m_height, 1);

    m_swsCtx = sws_getContext(m_width, m_height, AV_PIX_FMT_RGB24,
                              m_width, m_height, AV_PIX_FMT_YUV420P,
                              SWS_BILINEAR, nullptr, nullptr, nullptr);

    qDebug() << "✅ 开始录制:" << filename << m_width << "x" << m_height << "@" << m_fps << "fps";
    m_frameCounter = 0;
    return true;
}

void VideoRecorder::addFrame(const QImage &image)
{
    if (!m_recording || !m_codecCtx) return;

    QImage img = image.convertToFormat(QImage::Format_RGB888);
    if (img.width() != m_width || img.height() != m_height) {
        img = img.scaled(m_width, m_height, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    }
    img.save("output.bmp");
    uint8_t *srcData[1] = { img.bits() };
    int srcLinesize[1] = { img.bytesPerLine() };

    sws_scale(m_swsCtx, srcData, srcLinesize, 0, m_height,
              m_yuvFrame->data, m_yuvFrame->linesize);

    // ✅ 使用 m_frameCounter 替代 m_stream->nb_frames_in_stream
    m_yuvFrame->pts = av_rescale_q(m_frameCounter, m_codecCtx->time_base, m_stream->time_base);
    m_frameCounter++;  // 👈 帧数递增

    AVPacket pkt;
    av_init_packet(&pkt);
    pkt.data = nullptr;
    pkt.size = 0;

    avcodec_send_frame(m_codecCtx, m_yuvFrame);
    while (avcodec_receive_packet(m_codecCtx, &pkt) == 0) {
        av_interleaved_write_frame(m_formatCtx, &pkt);
        av_packet_unref(&pkt);
    }
}

void VideoRecorder::stopRecording()
{
    if (!m_recording) return;

    avcodec_send_frame(m_codecCtx, nullptr);
    AVPacket pkt;
    av_init_packet(&pkt);
    while (avcodec_receive_packet(m_codecCtx, &pkt) == 0) {
        av_interleaved_write_frame(m_formatCtx, &pkt);
        av_packet_unref(&pkt);
    }

    av_write_trailer(m_formatCtx);
    closeEncoder();

    m_recording = false;
    m_frameCounter = 0;  // 可选：为下次录制准备
    qDebug() << "⏹️ 视频已保存:" << m_filename;
}

void VideoRecorder::closeEncoder()
{
    if (m_swsCtx) {
        sws_freeContext(m_swsCtx);
        m_swsCtx = nullptr;
    }
    if (m_yuvFrame) {
        av_frame_free(&m_yuvFrame);
        av_freep(&m_yuvBuffer);
    }
    if (m_codecCtx) {
        avcodec_close(m_codecCtx);
        avcodec_free_context(&m_codecCtx);
    }
    if (m_formatCtx && !(m_formatCtx->oformat->flags & AVFMT_NOFILE)) {
        avio_closep(&m_formatCtx->pb);
    }
    if (m_formatCtx) {
        avformat_free_context(m_formatCtx);
        m_formatCtx = nullptr;
    }
}
