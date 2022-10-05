import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

Item{
    id: mainContent
    anchors.fill: parent
    visible: !secondaryContent.visible

    readonly property alias workDescription: workDescription
    readonly property alias alertMsg: alertMsg

    Item{
        id: trackButtons
        width: main.width*0.4
        height: main.height*0.4 + 3
        anchors.centerIn: parent

        Image{
            id: playIcon
            source: images.play
            width: main.width*0.4
            height: main.height* 0.4
            visible: true
        }

        Image{
            id: pauseIcon
            source: images.pause
            width: main.width*0.4
            height: main.height* 0.4
            visible: false
        }

        MouseArea{
            anchors.fill: trackButtons
            onClicked: {
                trackButtons.focus = true
                if(main.state === 0 || main.state === 2){ // Tracking Started
                    if(main.state === 0){
                        main.tString = "00:00:00"
                        workDescription.text = settings.value("last-work-description","Work Description")
                        insertStart(workDescription.text)
                    }
                    main.state = 1
                    playIcon.visible = false
                    pauseIcon.visible = true
                    tracker.start()
                }
                else if(main.state === 1){// Tracking Paused
                    main.state = 2
                    playIcon.visible = true
                    pauseIcon.visible = false
                    tracker.stop()
                    insertEnd(main.tracked_time,workDescription.text)
                    main.tString = "Paused"
                }
            }
        }

    }

    Item{
        id: stopBtn
        anchors.left: trackButtons.right
        anchors.verticalCenter: trackButtons.verticalCenter
        width: side.width + 10
        height: side.height
        visible: main.state
        Rectangle{
            id:side
            height: trackButtons.height/2
            width: trackButtons.width/2
            radius: width/2
            color: Material.color(Material.Blue,Material.Shade700)
            anchors.centerIn: parent

            Image{
                source: images.stop
                height: parent.height
                width: parent.width
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    main.state = 0
                    playIcon.visible = true
                    pauseIcon.visible = false
                    tracker.stop()
                    insertEnd(tracked_time,workDescription.text)
                    main.tracked_time = 0
                    alertMsg.text = "Start Tracking"
                }
            }
        }
    }


    Rectangle{
        color: Material.color(Material.LightBlue,Material.Shade900)
        border.color: "#0066ff"
        border.width: 2
        radius: 10
        anchors.top: trackButtons.bottom
        anchors.horizontalCenter: trackButtons.horizontalCenter
        width: workDescription.width + 6
        height: workDescription.height + 5

        TextInput{
            id: workDescription
            anchors.centerIn: parent
            width: main.width/1.5
            font.pointSize: 8
            text: ""
            padding: {
                left: 5
                right: 5
                top: 2
                bottom: 2
            }

            onTextEdited: {
                settings.setValue("last-work-description",text)
            }

            Material.background: "white"
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            readOnly: false
            clip: true
            y: 20
        }
    }

    Rectangle{
        id: alert
        color: Material.color(Material.LightBlue,Material.Shade900)
        width: main.width/1.5
        height: 20
        radius: 5
        anchors.horizontalCenter: mainContent.horizontalCenter
        y: 20
        Material.elevation: 15
        border.color: "#0066ff"
        border.width: 2

        Behavior on opacity{
            NumberAnimation {
                target: rect
                property: "opacity"
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        Text{
            id: alertMsg
            anchors.centerIn: parent
            padding: 5
            width: main.width/2
            font.pointSize: 8
            text: "Start Tracking"
            Material.background: "white"
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            clip: true
            font.weight: Font.Bold
        }
    }
}
