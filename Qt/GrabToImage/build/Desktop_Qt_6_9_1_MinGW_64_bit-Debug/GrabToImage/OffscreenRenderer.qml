import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: offscreenRenderer
    width: 800
    height: 600

    // 离屏渲染的内容容器（不可见）
    Item {
        id: renderTarget
        width: parent.width
        height: parent.height
        visible: false  // 关键：隐藏离屏内容

        // 复杂的QML内容 - 这里以波形为例
        Rectangle {
            anchors.fill: parent
            color: backgroundColor

            // 动态背景色
            property color backgroundColor: "black"
            NumberAnimation on backgroundColor {
                from: "black"
                to: "darkblue"
                duration: 5000
                loops: Animation.Infinite
                easing.type: Easing.InOutQuad
            }

            // 波形效果
            Repeater {
                model: 200
                Rectangle {
                    id: waveElement
                    x: index * (parent.width / 200)
                    y: parent.height / 2 + Math.sin((index * 0.2) + animationTime) * 100
                    width: 4
                    height: 4
                    color: Qt.hsla((index / 200.0), 0.8, 0.6, 0.9)
                    radius: 2

                    // 动画时间
                    property real animationTime: 0
                    NumberAnimation on animationTime {
                        from: 0
                        to: Math.PI * 2
                        duration: 2000
                        loops: Animation.Infinite
                    }
                }
            }

            // 额外的视觉效果
            Repeater {
                model: 10
                Rectangle {
                    x: Math.random() * parent.width
                    y: Math.random() * parent.height
                    width: 20 + Math.random() * 30
                    height: 20 + Math.random() * 30
                    color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.3)
                    radius: width / 2
                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 4000 + Math.random() * 2000
                        loops: Animation.Infinite
                    }
                }
            }
        }
    }

    // 定时捕获离屏内容
    Timer {
        id: captureTimer
        interval: 33  // 约30 FPS
        repeat: true
        running: true

        onTriggered: {
            captureOffscreenContent()
        }
    }

    // 捕获函数
    function captureOffscreenContent() {
        // 使用grabToImage捕获离屏内容
        renderTarget.grabToImage(function(result) {
            // 发送捕获的图像到显示窗口
            offscreenRenderer.imageCaptured(result.image)
        }, Qt.size(renderTarget.width, renderTarget.height))
    }

    // 图像捕获信号
    signal imageCaptured(var image)

    // 控制函数
    function startCapture() {
        captureTimer.start()
    }

    function stopCapture() {
        captureTimer.stop()
    }

    function captureOnce() {
        captureOffscreenContent()
    }

    // 状态属性
    property bool isCapturing: captureTimer.running
    property int captureInterval: captureTimer.interval

    onCaptureIntervalChanged: {
        captureTimer.interval = captureInterval
    }
}
