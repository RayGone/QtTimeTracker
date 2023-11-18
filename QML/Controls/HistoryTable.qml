import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import "qrc:/Utilities/Utils.js" as Util

Column{
    id: workHistory
    signal replayJob()

    property var tableModel: []
    property var replayJobInfo: []
    property bool showReplay: false

    property alias noHistoryInfo: noHistoryInfo

    Row{
        width: parent.width
        TextTemplate{
            width: parent.width/3
            text: "Job Title"
            font.pointSize: 8 * app.scaleFactor
            horizontalAlignment: Text.AlignLeft
        }

        TextTemplate{
            width: parent.width/3
            text: "Work Date"
            font.pointSize: 8 * app.scaleFactor
            horizontalAlignment: Text.AlignLeft
        }

        TextTemplate{
            width: parent.width/3
            text: "Worked Time"
            font.pointSize: 8 * app.scaleFactor
            horizontalAlignment: Text.AlignLeft
        }
    }

    ToolSeparator{
        orientation: Qt.Horizontal
        width: parent.width
        padding: 0
    }

    TextTemplate{
        id: noHistoryInfo
        visible: !historyListView.model.length
        text: "<br><br><br>     No Work History!!       <br><b>Start a new job!!</b>"
        font.pointSize: 8 * app.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ScrollView{
        id: historyList
        height: parent.height - 45 * app.scaleFactor
        width: parent.width
        contentHeight: parent.height
        contentWidth: parent.width
        clip: true

        ListView{
            id: historyListView
            anchors.fill: parent
            model: tableModel
            delegate: Item{
                width: historyList.width
                height: dataDate.height + 10

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true

                    onEntered: {
                        replayBtn.width = 60 * app.scaleFactor
                    }

                    onExited: {
                        if(!replayBtn.hoverSemaphore)
                            replayBtn.width = 0
                    }
                }

                Rectangle{
                    id: replayBtn
                    width: 0
                    clip: true
                    height: roundBtn.height
                    anchors.right: parent.right
                    radius: 25
                    visible: showReplay

                    property int hoverSemaphore: 0

                    gradient: Gradient{
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: app.primaryColor}
                        GradientStop { position: 0.5; color: Color.transparent(app.primaryColor,0.5)}
                        GradientStop { position: 0.8; color: Color.transparent(app.primaryColor,0) }
                        GradientStop { position: 1; color: Color.transparent(app.primaryColor,0) }
                    }

                    HoverHandler{
                        id: replayBtnHover
                        enabled: true

                        onHoveredChanged: {
                            replayBtn.hoverSemaphore = replayBtn.hoverSemaphore ? 0 : 1
                            if(!replayBtn.hoverSemaphore) replayBtn.width = 0;
                        }
                    }

                    RoundButton{
                        id: roundBtn
                        icon.source: 'qrc:/Icons/play.png'
                        icon.color: app.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        Material.background: Material.color(Material.Grey,Material.Shade100)

                        onClicked: {
                            replayJobInfo = modelData;
                            replayJob();
                        }
                    }

                    Behavior on width{
                        NumberAnimation{
                            target: replayBtn
                            property: 'width'
                            duration: 500
                            easing.type: Easing.InCubic//Easing.InOutQuad
                        }
                    }
                }

                Row{
                    anchors.fill: parent

                    TextTemplate{
                        id: dataTitle
                        width: parent.width/3
                        text: modelData.job_title
                        font.pointSize: 8 * app.scaleFactor
                        horizontalAlignment: Text.AlignLeft
                        padding: 2
                    }

                    TextTemplate{
                        id: dataDate
                        width: parent.width/3
                        text: new Date(modelData.work_date).toLocaleDateString()
                        font.pointSize: 6 * app.scaleFactor
                        horizontalAlignment: Text.AlignLeft
                        padding: 2
                    }

                    TextTemplate{
                        id: dataTime
                        width: parent.width/3
                        text: Util.readableTimeString(modelData.logged_time)
                        font.pointSize: 8 * app.scaleFactor
                        horizontalAlignment: Text.AlignLeft
                        padding: {
                            top: 0
                            left: 15 * app.scaleFactor
                            bottom: 0
                        }
                    }
                }
            }
        }
    }

}
