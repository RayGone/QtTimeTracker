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
import "qrc:/Utilities/Utils.js" as Util

import "qrc:/QML/"
import "qrc:/QML/Controls"
import "qrc:/QML/MainWindow"
import "qrc:/Utilities"
import "qrc:/Icons"

ApplicationWindow {
    id: app

    //flags: //Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint

    width: 350 * scaleFactor
    height: 450 * scaleFactor

    minimumWidth: width
    minimumHeight: height

    maximumWidth: width
    maximumHeight: height

    property real defaultAppWidth: 350 * scaleFactor
    property real defaultAppHeight: 450 * scaleFactor

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
    readonly property string secondaryFontFamily: "Helvetica"
    property string primaryColor: Material.color(Material.LightBlue,Material.Shade900)
    property string secondaryColor: Material.color(Material.Purple,Material.Shade900)
    property date today: new Date()

    property alias settings: settings
    property alias systemTrayIcon: systemTrayIcon
    readonly property alias trackerInfo: trackerInfo

    QtObject{
        id: trackerInfo

        // App Tracking State Flags----------
        readonly property string flagIdle: 'track:no' // This state suggests that currently no job is being tracked
        readonly property string flagTracking: 'track:running' // This state suggests that currently a job is being tracked
        readonly property string flagPaused: 'track:paused' // This state suggests that a job is being tracked but currently paused

        //------State Info-------
        property string tString: "TimeTracker"
        property int trackedTime: 0
        property string state: flagIdle
        property string jobID: ''
        property string jobTitle: ''
        property string jobDesc: ''

        function changeStateIdle(){
            if(state !== flagIdle){                
                dbOps.updateLog(app.trackerInfo) //log before exiting the app
                var msg = "You have stopped logging your time for the job ["+app.trackerInfo.jobTitle + "]"
                systemTrayIcon.showMessage("Job Stopped!!",msg)

                state = flagIdle
                trackedTime = 0
                jobID = ''
                jobTitle = ''
                jobDesc = ''
            }
        }

        function changeStateTracking(){
            if(state !== flagTracking)
                state = flagTracking
        }

        function changeStatePaused(){
            if(state !== flagPaused){
                //var msg = "You have paused logging your time for the job ["+app.trackerInfo.jobTitle + "]\nContinue when ready!!!"
                //systemTrayIcon.showMessage("Tracking Paused!!",msg)
                state = flagPaused
            }
        }
    }

    onClosing: {
        if(settings.value("app-first-close",true)){
            settings.setValue("app-first-close",0);
            systemTrayIcon.showMessage("App Running In Background!!!","You can access the app menu on system tray on task bar menu.")
        }
        appClosed = true
    }

    Component.onCompleted: {
        console.log(app.scaleFactor,height,width)
        //console.log(SystemInformation.machineUniqueId)
        //console.log(Util.generateUuid())

        database = LocalStorage.openDatabaseSync("TimeTrackerV2", "1.0", "Database used by TimeTracker App to store data", 1000000);
        dbOps.createDatabase()

        view.push(mainPage)
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

        onCurrentItemChanged: {
            if(currentItem.objectName === 'front-view') currentItem.refreshHistory();
        }
    }

    Component{
        id: mainPage

        MainWindow{
            objectName: "front-view"
            onStartTracking: {
                app.trackerInfo.changeStateTracking();
                view.push(trackPage);

                if(!app.trackerInfo.jobID){
                    app.trackerInfo.jobID = Util.generateUuid();
                    dbOps.startLog(app.trackerInfo);
                }
            }

            onOpenReports: {
                view.push(reportPage)
            }
        }
    }

    Component{
        id: reportPage

        ReportView{
            objectName: 'report-view'
            onBack: view.pop();
        }
    }

    Component{
        id: trackPage

        TrackerView{
            objectName: 'tracker-view'

            Component.onCompleted: {
                htitle.textElem.text = "Current Job: <b>[" + app.trackerInfo.jobTitle + "]</b>"
            }

            onPauseTracking: {
                app.trackerInfo.changeStatePaused()
            }

            onContinueTracking: {
                app.trackerInfo.changeStateTracking()
            }

            onStopTracking: {
                //Call DB function here to insert the final value
                app.trackerInfo.changeStateIdle()
                view.pop();
            }
        }
    }

    FramelessWindow{
        id: backgroundTracker
        objectName: 'frameless-window'

        height: app.width/3
        width: app.width/3
        visible: app.appClosed && (app.trackerInfo.state != app.trackerInfo.flagIdle)
    }

    /*
      -------------------------------------------------------
      -----------------Visible Items End---------------------
      -------------------------------------------------------
     */

    Database{
        id: dbOps
    }    

    Settings{
        id: settings
    }

    Images{
        id: images
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

    /*
      -------------------------------------------------------
      ----------------------System Timer---------------------
      -------------------------------------------------------
      */

    Timer{
        id: tracker
        interval: 1000
        repeat: true
        running: app.trackerInfo.state === app.trackerInfo.flagTracking

        onTriggered:{
            if(app.trackerInfo.trackedTime%60 == 0){
               dbOps.updateLog(app.trackerInfo)
            }

            app.trackerInfo.trackedTime += 1
            app.trackerInfo.tString = Util.computeTrackedReadableTimeString(app.trackerInfo.trackedTime)
        }
    }

    //    Timer{
    //        id: trigger
    //        running: !active
    //        interval: 120000
    //        repeat: true
    //        onTriggered: {
    //            if(trackerWindow.opacity === 0.4) trackerWindow.opacity = 0.2;
    //            else {
    //                if(!trackedTime) showMinimized();
    //                console.log('App Inactive: Minimizing');
    //                repeat = false
    //            }
    //        }
    //    }

    Timer{
        id: pauseFlash
        running: app.trackerInfo.state === app.trackerInfo.flagPaused
        repeat: true
        interval: 3000

        onTriggered: {
            app.trackerInfo.tString = app.trackerInfo.tString === "Paused" ? Util.computeTrackedReadableTimeString(app.trackerInfo.trackedTime) : "Paused";
        }
    }

    //-----------
    // System Tray Icon
    //-------------

    SystemTrayIcon {
        id: systemTrayIcon
        visible: true
        icon.mask: true
        icon.source: "qrc:/app-icon.ico"
        tooltip: "TimeTracker"
        menu: Menu {
                id: systemTrayMenu
                Material.background: Material.color(Material.Grey,Material.Shade100)

                MenuItem{
                    text: qsTr("Open App")
                    //shortcut: StandardKey.Open
                    onTriggered: {
                        showMainWindow()
                    }
                }

                MenuItemGroup{
                    id: floatingTrackerMenu
                    visible: backgroundTracker.visible
                }

                MenuSeparator{group: floatingTrackerMenu}
                MenuItem{
                    text: qsTr("Hide Floating Tracker")
                    group: floatingTrackerMenu
                    //shortcut: StandardKey.Open
                    onTriggered: {
                        backgroundTracker.close();
                    }
                }

                MenuItemGroup{
                    id: trackerFunctionMenu
                    visible: app.trackerInfo.state !== app.trackerInfo.flagIdle
                }

                MenuItem{
                    group: trackerFunctionMenu
                    separator: true
                }

                MenuItem{
                    text: qsTr("Continue")
                    group: trackerFunctionMenu
                    //shortcut: StandardKey.Cancel
                    onTriggered: {
                        app.trackerInfo.changeStateTracking()
                    }
                }

                MenuItem{
                    text: qsTr("Pause")
                    group: trackerFunctionMenu
                    //shortcut: StandardKey.Cancel
                    onTriggered: {
                        app.trackerInfo.changeStatePaused()
                    }
                }
                MenuItem{
                    text: qsTr("Stop")
                    group: trackerFunctionMenu
                    //shortcut: StandardKey.Cancel
                    onTriggered: {
                        if(backgroundTracker.visible)
                            backgroundTracker.close()
                        view.pop()
                        // This should be the last statement to be executed
                        app.trackerInfo.changeStateIdle()
                    }
                }

                MenuSeparator{}

                MenuItem{
                    text: qsTr("Quit")
                    shortcut: StandardKey.Close
                    role: MenuItem.QuitRole
                    onTriggered: {
                        app.trackerInfo.changeStateIdle()
                        Qt.quit()
                    }
                }
            }
    }
}
