import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: displayWindow
    width: 800
    height: 600
    title: "离屏渲染显示窗口"
    visible: false

    // 接收图像的属性
    property var currentImage: null
    property string statusText: "等待图像数据..."
    property bool showFps: true
    property int frameCount: 0
    property real lastTime: 0

    // 显示捕获的图像
    Image {
        id: displayImage
        anchors.fill: parent
        source: currentImage ? currentImage : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true

        // 加载状态指示
        BusyIndicator {
            anchors.centerIn: parent
            running: displayImage.status === Image.Loading
            visible: running
        }

        // 错误提示
        Text {
            anchors.centerIn: parent
            text: {
                switch(displayImage.status) {
                case Image.Null:
                    return "无图像数据"
                case Image.Ready:
                    return ""
                case Image.Loading:
                    return "加载中..."
                case Image.Error:
                    return "图像加载错误"
                default:
                    return "未知状态"
                }
            }
            color: "white"
            font.pixelSize: 20
            visible: displayImage.status !== Image.Ready
        }
    }

    // 状态栏
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 30
        color: "#222222"
        visible: true

        Row {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            Text {
                text: statusText
                color: "white"
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: fpsText
                text: showFps ? "FPS: " + calculateFps() : ""
                color: "lightgreen"
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                visible: showFps
            }
        }
    }

    // FPS计算
    function calculateFps(): string {
        var currentTime = Date.now()
        var fps = 0

        if (lastTime > 0) {
            var deltaTime = currentTime - lastTime
            if (deltaTime > 0) {
                fps = (1000 / deltaTime).toFixed(1)
            }
        }

        lastTime = currentTime
        frameCount++

        return fps.toString()
    }

    // 接收图像数据的方法
    function setImage(image) {
        currentImage = image
        statusText = "图像已更新 - " + new Date().toLocaleTimeString()
    }

    // 清除图像
    function clearImage() {
        currentImage = null
        statusText = "图像已清除"
    }

    // 控制菜单
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: "清除图像"
            onTriggered: clearImage()
        }

        MenuItem {
            text: "切换FPS显示"
            onTriggered: showFps = !showFps
        }

        MenuItem {
            text: "窗口置顶"
            onTriggered: displayWindow.raise()
        }

        MenuItem {
            text: "关闭窗口"
            onTriggered: displayWindow.close()
        }
    }
}
