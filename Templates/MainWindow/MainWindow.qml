import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import 'qrc:/Templates/'

Page {
    id: mainPage

    signal startTracking()

    header: ToolBar{
        Material.background: Material.color(Material.Grey,Material.Shade50)
        Column{
            anchors.fill: parent
            HeadTitle{
                radius: 0
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        newJob.open()
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("MainWindow Build")
    }

    StartJobPrompt{
        id: newJob
        width: mainPage.width
        height: mainPage.height/2

        onStart: {
            //console.log("Start Tracking")
            startTracking()
        }
    }

    function computeTime(seconds){
        var minutes = seconds / 3600
        var hours = parseInt(minutes)
        minutes = Math.ceil((minutes - hours) * 60)

        return (hours? hours + " hour" : "") + " " + (minutes ? minutes + " minutes" : "")
    }

    Pane{
        anchors.fill: parent
        Column{
            anchors.fill: parent
            spacing: 2 * app.scaleFactor

            Rectangle{
                width: parent.width
                height: 30 * app.scaleFactor
                TextTemplate{
                    padding: 5
                    text: 'Recent Work History'
                }
                color: Color.transparent(app.primaryColor,0.5)
                radius: 5

                DumpReport{
                    id: reportBtn
                    height: 30 * app.scaleFactor
                    width: 30 * app.scaleFactor
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    imgSrc: "qrc:/Icons/dump.png"

                    onOpen: {

                    }
                }
            }

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
                    model: app.dbOps.getWorkHistory()
                    delegate: Row{
                        width: historyList.width
                        TextTemplate{
                            width: parent.width/3
                            text: modelData.work
                            font.pointSize: 8 * app.scaleFactor
                            horizontalAlignment: Text.AlignLeft
                        }

                        TextTemplate{
                            width: parent.width/3
                            text: new Date(modelData.start * 1000).toLocaleDateString()
                            font.pointSize: 6 * app.scaleFactor
                            horizontalAlignment: Text.AlignLeft
                        }

                        TextTemplate{
                            width: parent.width/3
                            text: computeTime(modelData.tracked_time)
                            font.pointSize: 8 * app.scaleFactor
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }
        }
    }
}
