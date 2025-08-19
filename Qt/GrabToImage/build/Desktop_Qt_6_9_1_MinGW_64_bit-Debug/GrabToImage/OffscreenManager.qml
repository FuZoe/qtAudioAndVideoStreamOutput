import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: offscreenManager
    width: 800
    height: 600

    // 离屏内容
    Item {
        id: renderContent
        width: parent.width
        height: parent.height
        visible: false  // 隐藏渲染内容

        // 你的复杂QML内容
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "darkblue" }
                GradientStop { position: 1.0; color: "black" }
            }

            // 动态内容
            Repeater {
                model: 50
                Rectangle {
                    x: Math.random() * parent.width
                    y: Math.random() * parent.height
                    width: 30 + Math.random() * 50
                    height: 30 + Math.random() * 50
                    color: Qt.hsla(Math.random(), 0.8, 0.6, 0.7)
                    radius: width / 2
                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 3000 + Math.random() * 2000
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
            // 捕获离屏内容为图像
            renderContent.grabToImage(function(result) {
                // 发送图像到显示窗口
                offscreenManager.imageCaptured(result.image)
            }, Qt.size(renderContent.width, renderContent.height))
        }
    }

    // 图像捕获信号
    signal imageCaptured(var image)

    // 控制方法
    function startCapture() {
        captureTimer.start()
    }

    function stopCapture() {
        captureTimer.stop()
    }
}
