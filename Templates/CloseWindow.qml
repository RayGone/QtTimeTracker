import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Rectangle{
    id: closeWindow
    width: 24
    height: 24
    radius: width/2
    color: Material.color(Material.Blue,Material.Shade700)
    border.color: Material.color(Material.Blue,Material.Shade900)
    border.width: 2
    visible: active
    anchors.right: parent.right

    property string imgSrc: ""

    Image{
        width: parent.width * 0.5
        height: parent.height * 0.5
        anchors.centerIn: parent
        source: imgSrc
    }

    MouseArea{
        anchors.fill: parent

        onClicked: {
            saveTimeBeforeClose()
            close()
        }
    }
}
