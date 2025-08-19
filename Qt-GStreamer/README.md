需要注意的是，Qt-GStreamer的官方示例库早就在7年前停止了维护：https://github.com/GStreamer/qt-gstreamer

Qt官方对于GStreamer的说明：https://doc.qt.io/qt-6/qtmultimedia-gstreamer.html
说明中也提到"Seeking, playback rates, loop, switching sinks have known bugs."（Qt-GStreamer搜索、播放速率、循环、切换接收器均存在已知错误。)

因此，不管是对于初学者，还是注重开发效率的技术人员，**不建议使用Qt-GStreamer技术栈**

本文件夹下是一些Qt-GStreamer的Demo，需要注意的是，由于开发环境不同，可能会出现一些无法消除的报错弹窗(不影响功能使用)。

目录：
1.播放本地视频。点击：Qt-GStreamer\QtGStrmPipe-main （可修改视频路径，在main.cpp的：playbin uri=file:///D:/demo.mp4）
2.从摄像头捕获视频并显示在屏幕上。点击：https://github.com/FuZoe/CptVideoFrCamera