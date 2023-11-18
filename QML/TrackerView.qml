import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import "qrc:/QML/Controls"

Page{
    id: trackerView
    property alias htitle: htitle
    signal continueTracking()
    signal pauseTracking()
    signal stopTracking()

    header: HeadTitle{
            id: htitle
            radius: 0
        }

    Connections{
        target: app.trackerInfo

        function onTrackedTimeChanged(){
            trackerClock.nextStep(app.trackerInfo.trackedTime)
        }
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
                        visible: app.trackerInfo.state === app.trackerInfo.flagPaused
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
                        visible: app.trackerInfo.state === app.trackerInfo.flagTracking
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
        }
    }
}
