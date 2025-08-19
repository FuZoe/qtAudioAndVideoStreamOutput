#include <QApplication>
#include <QTimer>
#include <QWidget>
#include <QDebug>
#include <QFileInfo>
#include <QMainWindow>
#include <gst/gst.h>
#include <gst/video/videooverlay.h>

// Callback function to retrieve the actual video sink
static void on_child_added(GstChildProxy *proxy, GObject *object, gchar *name, gpointer user_data) {
    WId *window_handle = (WId *)user_data;
    if (GST_IS_VIDEO_OVERLAY(object)) {
        qDebug() << "Setting video overlay for element:" << name;
        gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(object), (guintptr)(*window_handle));
    }
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // 创建一个主窗口
    QMainWindow window;
    window.setWindowTitle("Video Player");
    window.resize(800, 600);
    
    gst_init(&argc, &argv);

    // 检查文件是否存在
    QString filePath = "D:\\demo.mp4";
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists()) {
        qDebug() << "Error: File does not exist:" << filePath;
        return -1;
    }
    qDebug() << "File exists:" << filePath;

    // 显示窗口并获取窗口句柄
    window.show();
    WId window_handle = window.winId();
    qDebug() << "Window handle:" << window_handle;

    // 直接使用playbin（唯一成功的方案）
    GstElement *pipeline = gst_parse_launch("playbin uri=file:///D:/demo.mp4", NULL);
    if (!pipeline) {
        qDebug() << "Failed to create playbin pipeline";
        return -1;
    }
    
    qDebug() << "Playbin pipeline created successfully";

    // 为playbin设置视频sink
    GstElement *videosink = gst_element_factory_make("autovideosink", "videosink");
    if (videosink) {
        g_object_set(G_OBJECT(pipeline), "video-sink", videosink, NULL);
        g_signal_connect(videosink, "child-added", G_CALLBACK(on_child_added), &window_handle);
        
        qDebug() << "Starting playbin...";
        GstStateChangeReturn ret = gst_element_set_state(pipeline, GST_STATE_PLAYING);
        if (ret == GST_STATE_CHANGE_FAILURE) {
            qDebug() << "Failed to start playbin";
            gst_object_unref(GST_OBJECT(pipeline));
            return -1;
        }
        
        qDebug() << "Playbin started successfully!";
    } else {
        qDebug() << "Failed to create videosink";
        gst_object_unref(GST_OBJECT(pipeline));
        return -1;
    }

    // 运行Qt应用
    int app_ret = app.exec();

    // 清理
    if (pipeline) {
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(GST_OBJECT(pipeline));
    }

    return app_ret;
}
