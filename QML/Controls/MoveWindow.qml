import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Rectangle{
    id: moveWindow
    width: 20
    height: 20
    radius: width/2
    color: "white"
    border.color: Material.color(Material.Blue,Material.Shade900)
    border.width: 2

    property string imgSrc: ""

    Image{
        width: parent.width
        height: parent.height
        source: imgSrc
    }

    MouseArea{
        anchors.fill: parent

        property double prevX
        property double prevY

         onPressed: {
             prevX = mouseX
             prevY = mouseY
         }

         onMouseXChanged: {
             var dx = mouseX - prevX
             main.setX(main.x + dx)
             settings.setValue("window-position",JSON.stringify({x: main.x,y:main.y}))
         }

         onMouseYChanged: {
             var dy = mouseY - prevY
             main.setY(main.y + dy)
             settings.setValue("window-position",JSON.stringify({x: main.x,y:main.y}))
         }
    }
}
