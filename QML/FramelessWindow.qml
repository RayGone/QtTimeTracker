import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import 'qrc:/QML/Controls'

Window{
    id: frameless
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    opacity: 0.3
    color: 'transparent'

    signal changeState()

    onActiveChanged: {
        if(active) opacity = 0.5
        else opacity = 0.3
    }

    Component.onCompleted: {
        setX(Screen.width - (width + 10 * app.scaleFactor))
        setY(Screen.height - (height + 50 * app.scaleFactor))
    }

    Connections{
        target: app.trackerInfo

        function onTrackedTimeChanged(){
            trackerClock.nextStep(app.trackerInfo.trackedTime)
        }
    }

    MouseArea{
        id: moveWindow
        anchors.fill: parent

        property double prevX
        property double prevY

        onDoubleClicked: {
            changeState()
            animation.width = frameless.width;
        }

        onPressed: {
            prevX = mouseX
            prevY = mouseY
        }

        onMouseXChanged: {
            var dx = mouseX - prevX
            frameless.setX(frameless.x + dx)
        }

        onMouseYChanged: {
            var dy = mouseY - prevY
            frameless.setY(frameless.y + dy)
        }
    }

    TemplateBody{
        id: trackerWindow
        visible: true
        anchors.fill: parent
        anchors.centerIn: parent
        radius: width/2

        Rectangle{
            id: animation
            width: 0
            height: width
            radius: width/2
            anchors.centerIn: parent
            color: app.secondaryColor

            Behavior on width{
                NumberAnimation{
                    target: animation
                    property: 'width'
                    duration: 100
                    easing.type: Easing.InCubic//Easing.InOutQuad
                }
            }

            Timer{
                repeat: false
                interval: 150
                running: animation.width > 0

                onTriggered: {
                    animation.width = 0
                }
            }
        }

        TrackerDisplay{
            id: trackerClock

            anchors.fill: parent
            timeDisplayText.color: 'white'
            timeDisplayText.font.pointSize: 10 * app.scaleFactor
            diameter: parent.width - 20

            miniProgressStrokeColor: app.primaryColor
            property int majorLineWidth: 6
            property int animationDuration: 1000
            //property var colorList: [
            //    Material.color(Material.Grey,Material.Shade900),
            //    Material.color(Material.Grey,Material.Shade100),
            //    Material.color(Material.Green,Material.Shade900),
            //    Material.color(Material.Red,Material.Shade900),
            //    Material.color(Material.DeepPurple,Material.Shade900),
            //    Material.color(Material.Yellow,Material.Shade900),
            //    Material.color(Material.Indigo,Material.Shade900),
            //    Material.color(Material.Lime,Material.Shade900),
            //]
        }
    }
}
