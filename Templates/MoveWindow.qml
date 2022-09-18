import QtQuick

Rectangle{
    width: 20
    height: 20
    radius: width/2
    color: white
    visible: active

    property double prevX
    property double prevY

    Image{
        width: parent.width
        height: parent.height
        source: images.move
    }

    MouseArea{
        anchors.fill: parent

         onPressed: {
             prevX = mouseX
             prevY = mouseY
         }

         onMouseXChanged: {
             var dx = mouseX - prevX
             main.setX(main.x + dx)
         }

         onMouseYChanged: {
             var dy = mouseY - prevY
             main.setY(main.y + dy)
         }
    }
}
