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
    property int frameCount: 0
    property bool isRecording: false

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

/*    // 点击视频进行切换
    Button {
        id: selectVideo1
        width: 90
        height: 22
        text: qsTr("捕获视频1")
        anchors.left: parent.left
        anchors.top: button.bottom
        anchors.leftMargin: 20
        anchors.topMargin: 10
        onClicked: combbox_index = 1
    }

    Button {
        id: selectVideo2
        width: 90
        height: 22
        text: qsTr("捕获视频2")
        anchors.left: parent.left
        anchors.top: button2.bottom
        anchors.leftMargin: 340
        anchors.topMargin: 10
        onClicked: combbox_index = 2
    }
*/

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
                    onClicked: {
                        toggleContinuousCapture()
                        isRecording ? stopRecording() : startRecording()
                    }
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
                        value: 30  // 默认30 FPS
                        onValueChanged: {
                            captureTimer.interval = 1000 / value
                        }
                        width: 150
                    }
                }

                ComboBox {
                    id: comboBox
					model: ["offscream", "video1", "video2", "video3"]
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
    // 视频播放器1
    MediaPlayer {
        id: mediaPlayer
        source: "file:///C:/Users/User/Videos/video1.mp4"  // 设置视频路径
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

	// 视频播放器2
	MediaPlayer {
		id: mediaPlayer2
		source: "file:///C:/Users/User/Videos/video2.mp4"  // 第二个视频路径
		onPlaybackStateChanged: {
			console.log("play2 status:", playbackState)
		}
		onErrorOccurred: {
			console.log("play2 error:", error, errorString)
		}
		autoPlay: true
		videoOutput: videoOutput2
		loops: MediaPlayer.Infinite
	}

	// 视频播放器3
	MediaPlayer {
		id: mediaPlayer3
		source: "file:///C:/Users/User/Videos/video3.mp4"  // 第三个视频路径
		onPlaybackStateChanged: {
			console.log("play3 status:", playbackState)
		}
		onErrorOccurred: {
			console.log("play3 error:", error, errorString)
		}
		autoPlay: true
		videoOutput: videoOutput3
		loops: MediaPlayer.Infinite
	}

	// 视频输出1
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

	// 视频输出2
	VideoOutput {
		id: videoOutput2
		anchors.fill: parent
		anchors.margins: 20
		anchors.leftMargin: 340
		anchors.rightMargin: 360
		anchors.topMargin: 500
		fillMode: VideoOutput.PreserveAspectFit
	}

	// 视频输出3
	VideoOutput {
		id: videoOutput3
		anchors.fill: parent
		anchors.margins: 20
		anchors.leftMargin: 660
		anchors.rightMargin: 40
		anchors.topMargin: 500
		fillMode: VideoOutput.PreserveAspectFit
	}

    // 定时器
	Button {
		id: button
		width: 80
		height: 16
		text: qsTr("hide video1")
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.leftMargin: 20
		anchors.topMargin: 480
		onClicked: {
			if(text === "hide video1"){
				text = "show video1"
				videoOutput.visible = false
			}
			else{
				text = "hide video1"
				videoOutput.visible = true
			}
		}
	}

	Button {
		id: button2
		width: 80
		height: 16
		text: qsTr("hide video2")
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.leftMargin: 340
		anchors.topMargin: 480
		onClicked: {
			if(text === "hide video2"){
				text = "show video2"
				videoOutput2.visible = false
			}
			else{
				text = "hide video2"
				videoOutput2.visible = true
			}
		}
	}

	Button {
		id: button3
		width: 80
		height: 16
		text: qsTr("hide video3")
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.leftMargin: 660
		anchors.topMargin: 480
		onClicked: {
			if(text === "hide video3"){
				text = "show video3"
				videoOutput3.visible = false
			}
			else{
				text = "hide video3"
				videoOutput3.visible = true
			}
		}
	}

    Timer {
        id: captureTimer
        interval: 33  // 默认33ms (30 FPS)
        repeat: true
        onTriggered: {
            captureOnce()
            if(isRecording)
                grabFrame()
        }
    }

    //新增的函数
    // Timer {
    //     id: captureTimer
    //     interval: 100
    //     repeat: true
    //     onTriggered: grabFrame()
    // }

    function startRecording() {
        if (isRecording) return
        frameCount = 0
        const width = 600, height = 400
        const filename = "output.mp4"
        if (videoRecorder.startRecording(filename, width, height, 30)) {
            isRecording = true
            //captureTimer.start()
        }
    }

    function stopRecording() {
        if (!isRecording) return
        //captureTimer.stop()
        videoRecorder.stopRecording()
        isRecording = false
    }

    function grabFrame() {
        videoOutput.grabToImage(function(result) { //videoOutput是第一个视频
            videoRecorder.addFrame(result.image)
            frameCount++ //捕获一帧之后,frameCount+1
            if (frameCount >= 300) stopRecording()
        })
    }
    //以上是新增的函数


    // 将捕获的内容显示函数
    function captureOnce() {
        //statusText.text = "正在捕获..."

		// 捕获离屏内容
		if(combbox_index === 0 ){
            offscreenContent.grabToImage(function(result) {
                displayImage.source = result.url
                statusText.text = "捕获完成 - " + new Date().toLocaleTimeString()
            }, Qt.size(offscreenContent.width, offscreenContent.height))
		}
		else if (combbox_index === 1){
			videoOutput.grabToImage(function(result) {
                displayImage.source = result.url
                statusText.text = "捕获完成 - " + new Date().toLocaleTimeString()
            }, Qt.size(offscreenContent.width, offscreenContent.height))
		}
		else if (combbox_index === 2){
			videoOutput2.grabToImage(function(result) {
				displayImage.source = result.url
				statusText.text = "捕获完成 - " + new Date().toLocaleTimeString()
			}, Qt.size(offscreenContent.width, offscreenContent.height))
		}
		else if (combbox_index === 3){
			videoOutput3.grabToImage(function(result) {
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
