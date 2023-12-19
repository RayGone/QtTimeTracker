import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls
import QtQuick.Controls.Material 2.15
import QtQuick.Effects
import 'qrc:/QML/Controls'
import 'qrc:/Utilities/Utils.js' as Util

Page {
    id: mainPage

    signal startTracking()
    signal openReports()

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

    Connections{
        target: app.trackerInfo

        function onStateChanged(){
            if(app.trackerInfo.isIdle()){
                refreshHistory();
            }
        }
    }

    function refreshHistory(){
        history.tableModel = app.dbOps.getRecentWorkHistory();
    }

    function prepareNewJob(title, description){
        app.trackerInfo.jobTitle = title
        app.trackerInfo.jobDesc = description
        startTracking()
    }

    function linkToOldJob(jobInfo){
        app.trackerInfo.jobID = jobInfo.job_id
        app.trackerInfo.jobTitle = jobInfo.job_title
        app.trackerInfo.jobDesc = jobInfo.job_desc
        app.trackerInfo.trackedTime = jobInfo.logged_time
        startTracking()
    }

    StartJobPrompt{
        id: newJob
        width: mainPage.width
        height: mainPage.height/1.9

        onStart: prepareNewJob(title, description)
    }

//    MonthGrid{
//        id: calendar
//        month: app.today.getMonth()
//        year: app.today.getFullYear()

//        function onClicked(date) {
//            console.log(date)
//        }
//    }

    Pane{
        anchors.fill: parent
        Column{
            anchors.fill: parent
            spacing: 3 * app.scaleFactor

            Rectangle{
                id: row1
                width: parent.width
                height: 30 * app.scaleFactor
                color: Color.transparent(app.primaryColor,0.5)
                radius: 5

                TextTemplate{
                    padding: 5
                    text: 'Recent Work History'
                }

                TextTemplate{
                    padding: 5
                    text: 'View Reports'
                    anchors.right: openReportBtn.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: openReportBtn.visible
                    font.pointSize: 7 * app.scaleFactor
                }

                DumpReport{
                    id: openReportBtn
                    height: 30 * app.scaleFactor
                    width: 30 * app.scaleFactor
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    imgSrc: "qrc:/Icons/dump.png"

                    onOpenClicked: {
                        openReports()
                    }
                }
            }

            HistoryTable{
                id: history
                width: parent.width
                height: parent.height - row1.height
                spacing: 3 * app.scaleFactor
                showReplay: true
                tableModel: []

                onReplayJob: {
                    var rji = app.dbOps.getLatestOfJob(replayJobInfo.job_title)
                    if(rji){
                        if(Util.getDateString(app.today) === Util.getDateString(new Date(rji.work_date))){
                            // start - update to db
                            linkToOldJob(rji)
                            return
                        }
                    }

                    //-- ELSE ---
                    // use job title and desc to start - insert new to db
                    prepareNewJob(rji.job_title,rji.job_desc)
                }
            }
        }
    }
}
