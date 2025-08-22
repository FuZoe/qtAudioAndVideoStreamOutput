想象一下 Qt Multimedia 模块是一个多功能的播放器外壳。这个外壳本身提供了所有用户能看到的按钮，比如“播放”、“暂停”、“停止”等标准接口。但是，这个外壳自己并不知道如何去解码和播放一部电影，比如一部 MP4 或者 MKV 格式的影片。

这时，就需要一个强大的“解码引擎”在后台默默工作。FFmpeg 就是这个解码引擎。

Qt6 的设计非常灵活，它允许你为播放器外壳（Qt Multimedia）选择不同的解码引擎。在 Windows 上，默认可能使用系统自带的媒体服务（WMF）；在 macOS 上，可能用 AVFoundation。而 FFmpeg 是一个跨平台的、功能极其强大的“万能解码引擎”，几乎支持所有已知的音视频格式。

所以，Qt6 将 FFmpeg 作为一个独立的、可插拔的后端插件。当你安装 Qt6 时，可以选择是否包含这个基于 FFmpeg 的多媒体后端。启用后，Qt Multimedia 模块就会在运行时加载这个插件，从而获得强大的音视频解码能力。

需要安装  qt6-multimedia 库及其 FFmpeg 插件（如 qt6-multimedia-ffmpeg），Qt6 可以利用 FFmpeg 的功能来处理音视频内容 

参考资料：

1.
官方API参考文档：https://ffmpeg.org/doxygen/trunk/

官方中文文档：https://ffmpeg.p2hp.com/documentation.html

2.源代码头文件（对于 C/C++ 开发者来说，最精准、最不会出错的文档其实就是头文件本身。FFmpeg 的开发者在头文件中留下了非常详尽的注释。

当你在你的项目中 #include 这些文件时，可以直接跳转到函数定义处查看：

libavformat/avformat.h

libavcodec/avcodec.h

libswscale/swscale.h

libavutil/frame.h (用于 AVFrame 结构体)

libavutil/pixfmt.h (用于像素格式定义)

这些头文件里的注释和 Doxygen 文档是同步的。）

3.官方示例代码

FFmpeg 官方提供了一系列示例代码，它们是学习如何正确组合使用这些 API 的最佳材料。

你可以在 FFmpeg 源代码的 doc/examples 目录下找到它们。

下载 FFmpeg 源代码: git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg

进入示例目录: cd ffmpeg/doc/examples

其中，有一个文件叫做 demuxing_decoding.c，它非常经典，完整地展示了从打开文件、查找流、解码音视频、直到获取 AVFrame 的全过程。


### 我仓库中的Demo如下：

1.[雷神的FFmpeg播放视频的Demo](https://github.com/FuZoe/ffmpeg_simple_player/releases/tag/VS) 注：点进去以后下载ffmpeg_simple_player.7z文件。代码有点老了，毕竟是2013年的

2.[GrabToImage & Save as FFmpeg](https://github.com/FuZoe/qtAudioAndVideoStreamOutput/tree/main/Qt/GrabToImage%20%26%20Save%20as%20FFmpeg) 通过GrabToImage一帧一帧地抓取图片，然后通过FFmpeg视频流输出到本地构建文件夹