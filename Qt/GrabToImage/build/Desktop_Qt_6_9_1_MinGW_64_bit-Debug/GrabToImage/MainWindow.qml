import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: mainWindow
    width: 600
    height: 500
    visible: true
    title: "离屏渲染控制器"

    // 离屏渲染器
    OffscreenRenderer {
        id: offscreenRenderer
        anchors.fill: parent
        visible: false  // 隐藏离屏渲染器本身

        // 连接图像捕获信号
        onImageCaptured: {
            // 将捕获的图像发送到显示窗口
            if (displayWindow.visible) {
                displayWindow.setImage(image)
            }
        }
    }

    // 显示窗口
    DisplayWindow {
        id: displayWindow
    }

    // 控制面板
    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "离屏渲染控制器"
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        // 控制按钮组
        GroupBox {
            title: "渲染控制"

            Column {
                spacing: 10
                width: 200

                Button {
                    text: offscreenRenderer.isCapturing ? "停止捕获" : "开始捕获"
                    onClicked: {
                        if (offscreenRenderer.isCapturing) {
                            offscreenRenderer.stopCapture()
                        } else {
                            offscreenRenderer.startCapture()
                        }
                    }
                    width: parent.width
                }

                Button {
                    text: "单次捕获"
                    onClicked: offscreenRenderer.captureOnce()
                    width: parent.width
                }

                Button {
                    text: displayWindow.visible ? "隐藏显示窗口" : "显示显示窗口"
                    onClicked: {
                        displayWindow.visible = !displayWindow.visible
                        if (displayWindow.visible) {
                            displayWindow.show()
                            displayWindow.raise()
                        } else {
                            displayWindow.hide()
                        }
                    }
                    width: parent.width
                }
            }
        }

        // 参数设置组
        GroupBox {
            title: "参数设置"

            Column {
                spacing: 10
                width: 200

                Text {
                    text: "捕获间隔: " + offscreenRenderer.captureInterval + "ms"
                }

                Slider {
                    id: intervalSlider
                    from: 16
                    to: 500
                    value: offscreenRenderer.captureInterval
                    stepSize: 1
                    onValueChanged: offscreenRenderer.captureInterval = value
                    width: parent.width
                }

                Text {
                    text: "分辨率: " + offscreenRenderer.width + "x" + offscreenRenderer.height
                }

                Row {
                    spacing: 10
                    width: parent.width

                    Button {
                        text: "720p"
                        onClicked: {
                            offscreenRenderer.width = 1280
                            offscreenRenderer.height = 720
                        }
                    }

                    Button {
                        text: "1080p"
                        onClicked: {
                            offscreenRenderer.width = 1920
                            offscreenRenderer.height = 1080
                        }
                    }
                }
            }
        }

        // 状态信息
        GroupBox {
            title: "状态信息"

            Column {
                spacing: 5
                width: 200

                Text {
                    text: "捕获状态: " + (offscreenRenderer.isCapturing ? "运行中" : "已停止")
                }

                Text {
                    text: "显示窗口: " + (displayWindow.visible ? "可见" : "隐藏")
                }

                Text {
                    text: "最后更新: " + new Date().toLocaleTimeString()
                }
            }
        }
    }

    // 底部状态栏
    footer: Rectangle {
        height: 30
        color: "#333333"

        Text {
            anchors.centerIn: parent
            text: "离屏渲染系统 - 使用 grabToImage()"
            color: "white"
            font.pixelSize: 12
        }
    }
}
