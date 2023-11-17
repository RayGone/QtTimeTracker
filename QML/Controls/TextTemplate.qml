import QtQuick 2.15

Text{
    font.pointSize: 10 * scaleFactor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    font.family: app.fontFamily
    elide: Text.ElideRight
}
