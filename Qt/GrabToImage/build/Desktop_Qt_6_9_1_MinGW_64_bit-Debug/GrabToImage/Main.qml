import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 6.0

Window {
    id: window
    width: 1000
    height: 700
    visible: true
    title: "离屏渲染演示"

    property int combbox_index:0

    // 离屏渲染内容（隐藏）
    Item {
        id: offscreenContent
        width: 800
        height: 600
        visible: false  // 关键：隐藏离屏内容

        // 示例内容 - 可以替换为你的波形渲染器
        Rectangle {
            anchors.fill: parent
            color: "black"

            // 动态波形效果
            Repeater {
                model: 200
                Rectangle {
                    x: index * 4
                    y: 300 + Math.sin((index * 0.1) + animationTime) * 100
                    width: 2
                    height: 4
                    color: "cyan"

                    property real animationTime: 0
                    NumberAnimation on animationTime {
                        from: 0
                        to: Math.PI * 4
                        duration: 3000
                        loops: Animation.Infinite
                    }
                }
            }

            // 装饰元素
            Repeater {
                model: 20
                Rectangle {
                    x: Math.random() * parent.width
                    y: Math.random() * parent.height
                    width: 10
                    height: 10
                    color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.7)
                    radius: 5
                }
            }
        }
    }

    // 主界面布局
    Column {
        anchors.fill: parent
        spacing: 20
        padding: 20

        Text {
            text: "离屏渲染演示"
            font.pixelSize: 24
            font.bold: true
            color: "black"
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Row {
            spacing: 30
            anchors.horizontalCenter: parent.horizontalCenter

            // 控制面板
            Column {
                spacing: 15
                width: 200

                Button {
                    text: "单次捕获"
                    onClicked: captureOnce()
                    width: parent.width
                }

                Button {
                    text: captureTimer.running ? "停止连续捕获" : "开始连续捕获"
                    onClicked: toggleContinuousCapture()
                    width: parent.width
                }

                Text {
                    id: statusText
                    text: "就绪"
                    color: "black"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }

                // 捕获频率控制
                Column {
                    spacing: 5

                    Text {
                        text: "捕获频率: " + (1000 / captureTimer.interval).toFixed(1) + " FPS"
                        color: "black"
                        font.pixelSize: 12
                    }

                    Slider {
                        id: fpsSlider
                        from: 1
                        to: 30
                        value: 10  // 默认10 FPS
                        onValueChanged: {
                            captureTimer.interval = 1000 / value
                        }
                        width: 150
                    }
                }

                ComboBox {
                    id: comboBox
                    model: ["offscream", "video"]
                    currentIndex: 0

                    onActivated: function(index) {
                        combbox_index = index
                    }
                }
            }

            // 显示区域
            Column {
                spacing: 10

                Text {
                    text: "捕获结果显示"
                    font.pixelSize: 16
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    width: 500
                }

                Rectangle {
                    width: 500
                    height: 400
                    border.color: "gray"
                    border.width: 2
                    color: "#f0f0f0"

                    Image {
                        id: displayImage
                        anchors.fill: parent
                        anchors.margins: 5
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true

                        // 加载指示器
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: displayImage.status === Image.Loading
                            visible: running
                        }

                        // 空状态提示
                        Text {
                            anchors.centerIn: parent
                            text: "点击'单次捕获'开始"
                            color: "gray"
                            visible: displayImage.source === ""
                        }
                    }
                }
            }
        }
    }
    // 视频播放器
    MediaPlayer {
        id: mediaPlayer
        source: "file:///D:/1.mp4"  // 设置视频路径
        onPlaybackStateChanged: {
            console.log("play status:", playbackState)
        }
        onErrorOccurred: {
            console.log("play error:", error, errorString)
        }
        // 自动播放（可选）
        autoPlay: true
        videoOutput: videoOutput
        loops: MediaPlayer.Infinite  // 无限循环
    }

    // 视频输出
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        anchors.margins: 20
        anchors.rightMargin: 700
        anchors.topMargin: 500
        fillMode: VideoOutput.PreserveAspectFit
        //visible: false

        // 可选：添加滤镜效果
        // filters: [ /* 视频滤镜 */ ]
    }

    // 定时器
    Button {
        id: button
        width: 80
        height: 16
        text: qsTr("hide video")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 480
        onClicked: {
            if(text === "hide video"){
                text = "show video"
                videoOutput.visible = false
            }
            else{
                text = "hide video"
                videoOutput.visible = true
            }
        }
    }

    Timer {
        id: captureTimer
        interval: 100  // 默认100ms (10 FPS)
        repeat: true
        onTriggered: captureOnce()
    }


    // 捕获函数
    function captureOnce() {
        //statusText.text = "正在捕获..."

        // 捕获离屏内容
        if(combbox_index === 0 ){
            offscreenContent.grabToImage(function(result) {
                displayImage.source = result.url
                statusText.text = "捕获完成 - " + new Date().toLocaleTimeString()
            }, Qt.size(offscreenContent.width, offscreenContent.height))
        }
        else{
            videoOutput.grabToImage(function(result) {
                displayImage.source = result.url
                statusText.text = "捕获完成 - " + new Date().toLocaleTimeString()
            }, Qt.size(offscreenContent.width, offscreenContent.height))
        }
    }

    // 切换连续捕获
    function toggleContinuousCapture() {
        if (captureTimer.running) {
            captureTimer.stop()
            statusText.text = "连续捕获已停止"
        } else {
            captureTimer.start()
            statusText.text = "开始连续捕获"
        }
    }
}
