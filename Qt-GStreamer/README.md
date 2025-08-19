需要注意的是，[Qt-GStreamer的官方示例库](https://github.com/GStreamer/qt-gstreamer)早就在7年前停止了维护.


[Qt官方对于GStreamer的说明](https://doc.qt.io/qt-6/qtmultimedia-gstreamer.html)中提到"Qt-GStreamer搜索、播放速率、循环、切换接收器均存在已知错误。"（Seeking, playback rates, loop, switching sinks have known bugs.)

[Qt官方对于Qt Multimedia的说明](https://doc.qt.io/qt-6/qtmultimedia-index.html)中也提到"GStreamer 后端仅在 Linux 上可用,并且仅推荐用于嵌入式应用程序。""GStreamer 后端有一些私有 API,以允许更细粒度的控制。"（The GStreamer backend is only available on Linux, and is only recommended for embedded applications.）（The GStreamer backend has some private APIs to allow more fine-grained control. )

因此，对于初学者，**不建议使用Qt-GStreamer技术栈**。但对于需要实现特定功能的开发者，可以考虑此方案。


本文件夹下是一些Qt-GStreamer的Demo，需要注意的是，由于开发环境不同，可能会出现一些无法消除的报错弹窗(不影响功能使用)。


目录：

1.播放本地视频。[Qt-GStreamer\QtGStrmPipe-main](https://github.com/FuZoe/qtAudioAndVideoStreamOutput/tree/main/Qt-GStreamer/QtGStrmPipe-main) （可修改视频路径，在main.cpp的：playbin uri=file:///D:/demo.mp4）

2.从摄像头捕获视频并显示在屏幕上。[前往另一个仓库](https://github.com/FuZoe/CptVideoFrCamera)

