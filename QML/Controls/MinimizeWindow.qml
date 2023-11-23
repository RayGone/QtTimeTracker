import QtQuick 2.15
import QtQuick.Controls.Material 2.15


Rectangle{
    id: minimizeWindow
    width: 20
    height: 20
    radius: width/2
    color: Material.color(Material.Blue,Material.Shade200)
    border.color: Material.color(Material.Blue,Material.Shade900)
    border.width: 2
    visible: active
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    property string imgSrc: ""

    Image{
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        source: imgSrc
    }

    MouseArea{
        anchors.fill: parent

        onClicked: {
            showMinimized()
        }
    }
}
