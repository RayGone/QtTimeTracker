import QtCore
import QtQml 2.15
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.LocalStorage 2.15

//import Qt.labs.settings 1.1
import Qt.labs.platform
import "qrc:/Templates"
import "qrc:/Templates/MainWindow"
import "qrc:/SQL"
import "qrc:/Icons"

ApplicationWindow {
    id: app

    width: 350 * scaleFactor
    height: 450 * scaleFactor

    minimumWidth: 350 * scaleFactor
    minimumHeight: 450 * scaleFactor

    visible: true
    title: qsTr("Time Tracker")
    //flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
    color: "transparent"

    property real scaleFactor: Screen.devicePixelRatio < 1 ? 1 : Screen.devicePixelRatio/2  // This is completely random thing

    property var database
    property real current_track_rowid: -1
    readonly property alias dbOps: dbOps

//    readonly property alias trackerProgress: secondaryContent.progressBar
//    readonly property alias workDescription: appContent.workDescription
//    readonly property alias alertMsg: mainContent.alertMsg

    property bool appClosed: false
    readonly property string fontFamily: 'Segoe Print'
    property string primaryColor: Material.color(Material.LightBlue,Material.Shade900)
    property date today: new Date()

    property alias settings: settings
    property alias systemTrayIcon: systemTrayIcon
    readonly property alias trackerInfo: trackerInfo

    QtObject{
        id: trackerInfo

        // App Tracking States ----------
        readonly property string flagIdle: 'state0'
        readonly property string flagTracking: 'state1'
        readonly property string flagStopped: 'state2'

        //-------------
        property string tString: "TimeTracker"
        property int trackedTime: 0
        property bool currentlyTracking: false
        property string state: ''

    }

    Settings{
        id: settings
    }

    Images{
        id: images
    }

    onClosing: {
        appClosed = true
    }

    Component.onCompleted: {
        console.log(app.scaleFactor,height,width)

//        var pos = JSON.parse(settings.value("window-position",false))

//        if(pos){
//            setX(pos.x)
//            setY(pos.y)
//        }else{
//            setX(Screen.width - (width+20))
//            setY(Screen.height - height*1.5)
//        }

        database = LocalStorage.openDatabaseSync("TimeTrackerV2", "1.0", "Database used by TimeTracker App to store data", 1000000);
        dbOps.createDatabase()

        view.push(mainPage)
        //workDescription.text = settings.value("last-work-description",false) ? "Prev: "+settings.value("last-work-description") : "Work Description"
    }



    function showMainWindow(){
        if(appClosed){
            app.show()
            app.raise()
            app.requestActivate()
            appClosed = !appClosed
        }
    }

    /*
      -------------------------------------------------------
      -----------------Visible Items Start-------------------
      -------------------------------------------------------
     */

    StackView{
        id: view

        initialItem: Item{

            AnimatedImage{
                id: animation
                width: 40
                height: 40
                source: 'qrc:/Icons/hourglass.gif'
                fillMode: Image.PreserveAspectFit
                //speed: 0.5
            }

            Image{
                id: appIcon
                source: 'qrc:/Icons/jobs.png'
                anchors.centerIn: parent
                width: 100 * app.scaleFactor
                height: width
            }

            TextTemplate{
                anchors.top: appIcon.bottom
                text: "Time Tracker"
                font.pointSize: 15 * app.scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        anchors.fill: parent
    }

    Component{
        id: mainPage

        MainWindow{
            onStartTracking: {
                app.trackerInfo.state = app.trackerInfo.flagTracking
                view.push(trackPage)
            }

            onOpenReports: {
                view.push(reportPage)
            }
        }
    }

    Component{
        id: reportPage

        ReportView{
            onBack: view.pop();
        }
    }

    Component{
        id: trackPage

        Page{

            header: HeadTitle{textElem.text: "Current Job's Title"}

            Column{
                anchors.fill: parent

                Row{
                    width: parent.width

                    TrackerDisplay{
                        id: trackerPage
                        width: parent.width/2
                        height: width
                        diameter: width * 0.8
                        visible: true
                        primaryColor: app.primaryColor

                        Connections{
                            target: app.trackerInfo

                            function onTrackedTimeChanged(){
                                trackerPage.progressBar.nextStep((app.trackerInfo.trackedTime)/60)
                            }
                        }
                    }

                    Column{
                        width: parent.width/2
                        spacing: 5 * app.scaleFactor
                        padding: {
                            left: 10 * app.scaleFactor
                        }

                        Divider{
                            width: parent.width
                            height: 20 * app.scaleFactor
                        }

                        TextTemplate{
                            text: "Continue"
                        }

                        TextTemplate{
                            text: "Pause"
                        }

                        TextTemplate{
                            text: "Stop"
                        }
                    }
                }
            }
        }
    }





//    TemplateBody{
//        id: trackerWindow
//        visible: false
//        width: app.width
//        height: app.height
//        anchors.centerIn: parent
//        radius: width/2

//        TrackerFunctions{
//            id: mainContent
//            anchors.fill: parent
//            visible: !secondaryContent.visible
//        }


//        WindowPeripheral{
//            id: buttons

//            width: app.width
//            height: app.height
//            visible: active

//            onDisplayReportView: {
//                reportview.visible = !reportview.visible
//            }
//        }

//        TrackerDisplay{
//            id: secondaryContent

//            diameter: mainContent.width
//            visible: false

//            MouseArea{
//                anchors.fill: parent

//                onClicked: {
//                    secondaryContent.visible = false
//                }
//            }

//            property int lineWidth: 10
//            property int animationDuration: 1000
//            property var colorList: [
//                Material.color(Material.Grey,Material.Shade900),
//                Material.color(Material.Grey,Material.Shade100),
//                Material.color(Material.Green,Material.Shade900),
//                Material.color(Material.Red,Material.Shade900),
//                Material.color(Material.DeepPurple,Material.Shade900),
//                Material.color(Material.Yellow,Material.Shade900),
//                Material.color(Material.Indigo,Material.Shade900),
//                Material.color(Material.Lime,Material.Shade900),
//            ]
//        }
//    }

    /*
      -------------------------------------------------------
      -----------------Visible Items End---------------------
      -------------------------------------------------------
     */


    Database{
        id: dbOps
    }

//    onActiveChanged: {
//        if(active){
//            showNormal()
//            trackerWindow.opacity = 1
//        }else{
//            trigger.repeat = true
//            trackerWindow.opacity = 0.3

//            if(app.state){
//                secondaryContent.visible = true
//            }
//        }
//    }

    Timer{
        id: trigger
        running: !active
        interval: 120000
        repeat: true
        onTriggered: {
            if(trackerWindow.opacity === 0.4) trackerWindow.opacity = 0.2;
            else {
                if(!trackedTime) showMinimized();
                console.log('App Inactive: Minimizing');
                repeat = false
            }
        }
    }

    Timer{
        id: tracker
        interval: 1000
        repeat: true
        running: app.trackerInfo.state === app.trackerInfo.flagTracking

        onTriggered:{
            app.trackerInfo.trackedTime += 1
            app.trackerInfo.tString = computeTrackedReadableTimeString()
//            alertMsg.text = tString

//            if(trackedTime == 1 || trackedTime%20 === 0)
//                trackerProgress.nextStep((trackedTime%3600)/3600)
//            //v+=0.1
//            //trackerProgress.nextStep(v)

//            if(trackedTime%60 === 0) insertEnd(trackedTime,workDescription.text)
        }
    }

    Timer{
        id: pauseFlash
        running: app.state === 2
        repeat: true
        interval: 3000

        onTriggered: {
            var tmp = app.tString === "Paused" ? computeTrackedReadableTimeString() : "Paused"
            alertMsg.text = tString = tmp
        }
    }

    function computeTrackedReadableTimeString(){
        var m = parseInt(app.trackerInfo.trackedTime/60)
        var s = app.trackerInfo.trackedTime - m*60
        var h = parseInt(m/60)
        m = m - h*60
        return (h<10? "0"+h : h) + " : " + (m<10? "0"+m : m) + " : " + (s<10 ? "0"+s : s)
    }



    //-----------
    // System Tray Icon
    //-------------

    SystemTrayIcon {
        id: systemTrayIcon
        visible: true
        icon.mask: true
        icon.source: "qrc:/clock-vector.ico"
        tooltip: "TimeTracker"
        menu: Menu {
                id: systemTrayMenu
                Material.background: Material.color(Material.Grey,Material.Shade100)

                MenuItem{
                    text: qsTr("Open App")
                    visible: appClosed
                    //shortcut: StandardKey.Open
                    onTriggered: {
                        showMainWindow()
                    }
                }

                MenuSeparator{
                    visible: appClosed
                }

                //                MenuItem{
                //                    visible: !appClosed
                //                    text: qsTr("Close")
                //                    //shortcut: StandardKey.Cancel
                //                    onTriggered: {
                //                        app.close()
                //                    }
                //                }

                //                MenuSeparator{
                //                    visible: !appClosed
                //                }

                MenuItem{
                    text: qsTr("Quit")
                    shortcut: StandardKey.Close
                    role: MenuItem.QuitRole
                    onTriggered: {
                        Qt.quit()
                    }
                }
            }
    }
}
