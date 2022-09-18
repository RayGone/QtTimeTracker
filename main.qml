import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: main
    width: 300
    height: 300
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width
    visible: true
    title: qsTr("Time Tracker")
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    color: "transparent"
    ColumnLayout{
        Layout.fillHeight: True
        Layout.fillWidth: True
        Rectangle{
            id: rect
            width: 250
            height: 250
            radius: width/2
            color: "red"
            anchors.centerIn: parent

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    main.alert(3000)
                    console.log('I am clicked')
                }
            }
        }
    }

    onActiveChanged: {
        if(active){
            showNormal()
            rect.opacity = 1;
        }else{
            rect.opacity = 0.8;
        }

    }

    Timer{
        running: !active
        interval: 1000
        onTriggered: {
            console.log(rect.opacity)
            if(rect.opacity > 1) rect.opacity = 0.6;
            else if(rect.opacity > 0.5) rect.opacity = 0.4;
            else {
                showMinimized();
                console.log('Here now, window should be minimized');
            }
        }
    }

}
