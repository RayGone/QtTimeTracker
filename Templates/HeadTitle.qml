import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15



Rectangle{
    height: 50 * app.scaleFactor
    Layout.preferredHeight: height
    width: parent.width
    Layout.preferredWidth: width
    color: app.primaryColor
    Material.background: app.primaryColor
    radius: 40 * app.scaleFactor

    property alias divider: frontPadding
    property alias logoElem: headerLogo
    property alias textElem: headerText

    RowLayout{
        spacing: 10 * app.scaleFactor
        anchors.fill: parent

        Divider{
            id: frontPadding
            Layout.preferredWidth: 5 * app.scaleFactor
            Layout.preferredHeight: 30 * app.scaleFactor
        }

        Image{
            id: headerLogo
            source: 'qrc:/Icons/jobs.png'
            Layout.preferredWidth: 30 * app.scaleFactor
            Layout.preferredHeight: 30 * app.scaleFactor
            fillMode: Image.PreserveAspectFit
            //anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignLeft
        }

        TextTemplate{
            id: headerText
            //anchors.centerIn: parent
            //Layout.alignment: Qt.AlignLeft
            text: 'Start a new job'
            font.bold: Font.Light
            color:"white"
        }
    }
}
