#include "GstStreamer.h"

#include <gst/gst.h>
#include <gst/app/gstappsrc.h>
#include <gst/video/video.h>
#include <QDebug>
#include <QVideoFrameFormat>

GstStreamer::GstStreamer(QObject *parent) : QObject(parent) {
    gst_init(nullptr, nullptr);
}

GstStreamer::~GstStreamer() {
    stop();
}

bool GstStreamer::start(const QString &host, int port, int width, int height, int fps) {
    stop();
    width_ = width;
    height_ = height;
    fps_ = fps;

    QString pipelineStr = QString(
        "appsrc name=mysrc is-live=true format=time caps=video/x-raw,format=RGBA,width=%1,height=%2,framerate=%3/1 ! "
        "videoconvert ! x264enc tune=zerolatency bitrate=2000 speed-preset=ultrafast key-int-max=30 ! "
        "rtph264pay config-interval=1 pt=96 ! udpsink host=%4 port=%5"
    ).arg(width_).arg(height_).arg(fps_).arg(host).arg(port);

    pipeline_ = gst_parse_launch(pipelineStr.toUtf8().constData(), nullptr);
    if (!pipeline_) {
        qWarning() << "Failed to create GStreamer pipeline";
        return false;
    }
    appsrc_ = gst_bin_get_by_name(GST_BIN(pipeline_), "mysrc");
    if (!appsrc_) {
        qWarning() << "Failed to get appsrc from pipeline";
        stop();
        return false;
    }

    gst_element_set_state(pipeline_, GST_STATE_PLAYING);
    running_ = true;
    return true;
}

void GstStreamer::stop() {
    if (pipeline_) {
        gst_element_set_state(pipeline_, GST_STATE_NULL);
        gst_object_unref(pipeline_);
        pipeline_ = nullptr;
    }
    appsrc_ = nullptr;
    running_ = false;
}

static QImage toRGBA(const QImage &src, int w, int h) {
    QImage img = src.convertToFormat(QImage::Format_RGBA8888);
    if (img.width() != w || img.height() != h) {
        img = img.scaled(w, h, Qt::IgnoreAspectRatio, Qt::FastTransformation);
    }
    return img;
}

bool GstStreamer::pushImage(const QImage &imgIn) {
    if (!running_ || !appsrc_) return false;

    QImage img = toRGBA(imgIn, width_, height_);
    const size_t dataSize = static_cast<size_t>(img.sizeInBytes());
    GstBuffer *buffer = gst_buffer_new_allocate(nullptr, dataSize, nullptr);
    if (!buffer) return false;

    GstMapInfo map;
    if (gst_buffer_map(buffer, &map, GST_MAP_WRITE)) {
        memcpy(map.data, img.constBits(), dataSize);
        gst_buffer_unmap(buffer, &map);

        GST_BUFFER_PTS(buffer) = gst_util_uint64_scale(g_get_monotonic_time(), GST_USECOND, 1);
        GST_BUFFER_DURATION(buffer) = gst_util_uint64_scale_int(1, GST_SECOND, fps_);

        GstFlowReturn ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc_), buffer);
        if (ret != GST_FLOW_OK) {
            qWarning() << "gst_app_src_push_buffer failed:" << ret;
            return false;
        }
        return true;
    }

    gst_buffer_unref(buffer);
    return false;
}

bool GstStreamer::pushVideoFrame(const QVideoFrame &frame) {
    if (!running_) return false;

    QVideoFrame f(frame);
    if (!f.map(QVideoFrame::ReadOnly)) return false;

    // Simplified path: wrap as QImage and reuse pushImage
    QImage img;
    switch (f.pixelFormat()) {
        case QVideoFrameFormat::Format_RGBA8888:
        case QVideoFrameFormat::Format_BGRA8888:
        case QVideoFrameFormat::Format_ARGB8888:
            img = QImage(f.bits(0), f.width(), f.height(), f.bytesPerLine(0), QImage::Format_RGBA8888);
            break;
        default:
            // Fallback: construct QImage and convert later
            img = QImage(f.bits(0), f.width(), f.height(), f.bytesPerLine(0), QImage::Format_RGBA8888);
            break;
    }

    bool ok = pushImage(img);
    f.unmap();
    return ok;
}
/*
// GstStreamer.cpp
#include "GstStreamer.h"
#include <gst/gst.h>
#include <gst/app/gstappsrc.h>
#include <gst/video/video.h>
#include <QVideoFrame>
#include <QVideoFrameFormat>
#include <QDebug>

GstStreamer::GstStreamer(QObject*) { gst_init(nullptr, nullptr); }
GstStreamer::~GstStreamer() { stop(); }

bool GstStreamer::start(const QString& host, int port, int w, int h, int fps) {
	stop();
	width_ = w; height_ = h; fps_ = fps;
	QString pipelineStr = QString(
		"appsrc name=mysrc is-live=true format=time caps=video/x-raw,format=RGBA,width=%1,height=%2,framerate=%3/1 ! "
		"videoconvert ! x264enc tune=zerolatency bitrate=2000 speed-preset=ultrafast key-int-max=30 ! "
		"rtph264pay config-interval=1 pt=96 ! udpsink host=%4 port=%5"
	).arg(w).arg(h).arg(fps).arg(host).arg(port);

	pipeline_ = gst_parse_launch(pipelineStr.toUtf8().constData(), nullptr);
	if (!pipeline_) return false;
	appsrc_ = gst_bin_get_by_name(GST_BIN(pipeline_), "mysrc");
	if (!appsrc_) { stop(); return false; }

	gst_element_set_state(pipeline_, GST_STATE_PLAYING);
	running_ = true;
	return true;
}

void GstStreamer::stop() {
	if (pipeline_) {
		gst_element_set_state(pipeline_, GST_STATE_NULL);
		gst_object_unref(pipeline_);
		pipeline_ = nullptr;
	}
	appsrc_ = nullptr;
	running_ = false;
}

static QImage toRGBA(const QImage& src, int w, int h) {
	QImage img = src.convertToFormat(QImage::Format_RGBA8888);
	if (img.width()!=w || img.height()!=h) img = img.scaled(w, h, Qt::IgnoreAspectRatio, Qt::FastTransformation);
	return img;
}

bool GstStreamer::pushImage(const QImage& imgIn) {
	if (!running_ || !appsrc_) return false;
	QImage img = toRGBA(imgIn, width_, height_);
	GstBuffer* buffer = gst_buffer_new_allocate(nullptr, img.sizeInBytes(), nullptr);
	GstMapInfo map;
	if (gst_buffer_map(buffer, &map, GST_MAP_WRITE)) {
		memcpy(map.data, img.constBits(), img.sizeInBytes());
		gst_buffer_unmap(buffer, &map);
		// 时间戳
		GST_BUFFER_PTS(buffer) = gst_util_uint64_scale(g_get_monotonic_time(), GST_USECOND, 1);
		GST_BUFFER_DURATION(buffer) = gst_util_uint64_scale_int(1, GST_SECOND, fps_);
		gst_app_src_push_buffer(GST_APP_SRC(appsrc_), buffer);
		return true;
	}
	gst_buffer_unref(buffer);
	return false;
}

bool GstStreamer::pushVideoFrame(const QVideoFrame& frame) {
	if (!running_) return false;
	QVideoFrame f(frame);
	if (!f.map(QVideoFrame::ReadOnly)) return false;
	QImage img;
	switch (f.pixelFormat()) {
		case QVideoFrameFormat::Format_RGBA8888:
		case QVideoFrameFormat::Format_BGRA8888:
		case QVideoFrameFormat::Format_ARGB8888:
			img = QImage(f.bits(0), f.width(), f.height(), f.bytesPerLine(0), QImage::Format_RGBA8888);
			break;
		default:
			// 兜底转成 QImage 再转 RGBA
			img = QImage(f.bits(0), f.width(), f.height(), f.bytesPerLine(0), QImage::Format_RGBA8888);
			break;
	}
	bool ok = pushImage(img);
	f.unmap();
	return ok;
}
*/