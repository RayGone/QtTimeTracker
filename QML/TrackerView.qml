import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import "qrc:/QML/Controls"
import "qrc:/Utilities/Utils.js" as Util

Page{
    id: trackerView
    property alias htitle: htitle
    signal continueTracking()
    signal pauseTracking()
    signal stopTracking()

    header: HeadTitle{
            id: htitle
            radius: 0

            textElem.text: app.trackerInfo.jobTitle
        }

    Connections{
        target: app.trackerInfo

        function onTrackedTimeChanged(){
            trackerClock.nextStep(app.trackerInfo.trackedTime)

            if(app.trackerInfo.trackedTime%60 == 1){ // here we check for 1 because the db update is bit delayed.
                history.tableModel = app.dbOps.getJobHistory(app.trackerInfo.jobTitle);
            }
        }

        function onJobTitleChanged(){
            htitle.textElem.text = "Current Job: <b>[" + app.trackerInfo.jobTitle + "]</b>"
        }
    }

    function setTotalLog(){
        var total = 0;
        for(var i in history.tableModel){
            total += history.tableModel[i]['logged_time']
        }

        totalLogText.text = "Total: " + Util.readableTimeString(total);
    }

    Column{
        anchors.fill: parent

        Row{
            id: row1
            width: parent.width

            TrackerDisplay{
                id: trackerClock
                width: parent.width/2.2
                height: width
                diameter: width * 0.8
                visible: true
                primaryColor: app.primaryColor
            }

            Column{
                width: parent.width/2
                spacing: 5 * app.scaleFactor
                padding: {
                    left: 10 * app.scaleFactor
                }

                Row{
                    id: trackFunctions
                    width: parent.width
                    spacing: 5

                    RoundButton{
                        id: continueBtn
                        visible: app.trackerInfo.isPaused()
                        icon.source: 'qrc:/Icons/play.png'
                        icon.color: app.primaryColor
                        Material.background: Color.transparent(app.primaryColor,0.5)

                        onClicked: {
                            continueTracking()
                        }
                    }

                    TextTemplate{
                        text: 'Play '
                        height: parent.height
                        visible: continueBtn.visible
                        font.pointSize: 5 * app.scaleFactor
                        verticalAlignment: Text.AlignVCenter
                    }

                    RoundButton{
                        id: pauseBtn
                        icon.source: 'qrc:/Icons/pause.png'
                        icon.color: app.primaryColor
                        visible: app.trackerInfo.isRunning()
                        Material.background: Color.transparent(app.primaryColor,0.5)

                        onClicked: {
                            pauseTracking()
                        }
                    }

                    TextTemplate{
                        text: 'Pause'
                        visible: pauseBtn.visible
                        height: parent.height
                        font.pointSize: 5 * app.scaleFactor
                        verticalAlignment: Text.AlignVCenter
                    }

                    RoundButton{
                        id: stopBtn
                        icon.source: 'qrc:/Icons/stop.png'
                        icon.color: app.primaryColor
                        Material.background: Color.transparent(app.primaryColor,0.5)

                        onClicked: {
                            stopTracking()
                        }
                    }

                    TextTemplate{
                        text: 'Stop'
                        height: parent.height
                        font.pointSize: 5 * app.scaleFactor
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Divider{
                    height: 5 * app.scaleFactor
                    width: parent.width
                }

                TextField{
                    id: jobTitle
                    placeholderText: "Job Title"
                    placeholderTextColor: focus ? app.primaryColor : Color.transparent(app.primaryColor,0.4)
                    width: parent.width
                    height: 30 * app.scaleFactor
                    Material.accent: app.primaryColor
                    maximumLength: 50
                    text: app.trackerInfo.jobTitle

                    onTextChanged: {
                        app.trackerInfo.jobTitle = text;
                    }
                }

                TextField{
                    id: jobDesc
                    placeholderText: "Job Description"
                    placeholderTextColor: focus ? app.primaryColor : Color.transparent(app.primaryColor,0.4)
                    width: parent.width
                    height: 30 * app.scaleFactor
                    Material.accent: app.primaryColor
                    maximumLength: 250
                    text: app.trackerInfo.jobDesc

                    onTextChanged: {
                        app.trackerInfo.jobDesc = text;
                    }
                }
            }
        }

        Row{
            id: row2
            width: parent.width
            padding: 5 * app.scaleFactor
            Rectangle{
                width: parent.width - parent.padding*2
                height: 30 * app.scaleFactor
                color: Color.transparent(app.primaryColor,0.5)
                radius: 5

                TextTemplate{
                    padding: 5
                    text: 'Work History'
                }

                TextTemplate{
                    id: totalLogText
                    padding: 5
                    anchors.right: parent.right
                    text: "Total: 0 hours"
                }
            }
        }

        HistoryTable{
            id: history
            width: parent.width - 10
            height: parent.height - (row1.height + row2.height)
            padding: 5 * app.scaleFactor
            spacing: 3 * app.scaleFactor
            tableModel: app.dbOps.getJobHistory(app.trackerInfo.jobTitle)

            noHistoryInfo.text: 'No Previous History Of This Job!!!'

            onTableModelChanged: {
                setTotalLog();
            }
        }
    }
}
