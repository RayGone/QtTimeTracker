import QtCore
import QtQml
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

    width: 400 * scaleFactor
    height: 500 * scaleFactor

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

    property real scaleFactor: 1//Screen.devicePixelRatio < 1 ? 1 : Screen.devicePixelRatio/2  // This is completely random thing

    property var database
    property real current_track_rowid: -1
    readonly property alias dbOps: dbOps

    property bool appClosed: false
    readonly property string fontFamily: 'Segoe Print'
    readonly property string secondaryFontFamily: "Helvetica"
    property string primaryColor: Material.color(Material.LightBlue,Material.Shade900)
    property string secondaryColor: Material.color(Material.LightBlue,Material.Shade400)
    property date today: new Date()

    property alias settings: settings
    property alias systemTrayIcon: systemTrayIcon
    readonly property alias trackerInfo: trackerInfo

    QtObject{
        id: trackerInfo

        //---------------------------------------
        // App Tracking State Flags----------
        //---------------------------------------
        readonly property string flagIdle: 'track:no' // This state suggests that currently no job is being tracked
        readonly property string flagTracking: 'track:running' // This state suggests that currently a job is being tracked
        readonly property string flagPaused: 'track:paused' // This state suggests that a job is being tracked but currently paused

        //---------------------------------------
        //------State Info-------
        //---------------------------------------
        property string tString: "TimeTracker"
        property int trackedTime: 0
        property string state: flagIdle
        property string jobID: ''
        property string jobTitle: ''
        property string jobDesc: ''

        function clear(){
            trackerInfo.tString = "TimeTracker";
            trackerInfo.trackedTime = 0;
            trackerInfo.state = flagIdle;
            trackerInfo.jobID = '';
            trackerInfo.jobTitle = '';
            trackerInfo.jobDesc = '';
        }

        //---------------------------------------
        //--------State Change Functions-------
        //---------------------------------------
        function changeStateIdle(){
            if(!isIdle()){
                dbOps.updateLog(app.trackerInfo) //log before exiting the app
                var msg = "You have stopped logging your time for the job ["+app.trackerInfo.jobTitle + "]"
                systemTrayIcon.showMessage("Job Stopped!!",msg)
            }

            clear();
        }

        function changeStateTracking(){
            if(!isRunning())
                state = flagTracking
        }

        function changeStatePaused(){
            if(!isPaused()){
                //var msg = "You have paused logging your time for the job ["+app.trackerInfo.jobTitle + "]\nContinue when ready!!!"
                //systemTrayIcon.showMessage("Tracking Paused!!",msg)
                state = flagPaused
            }
        }

        //---------------------------------------
        //----- State Check functions ------------
        //---------------------------------------
        function isRunning(){
            return state === flagTracking
        }

        function isPaused(){
            return state === flagPaused
        }

        function isIdle(){
            return state === flagIdle
        }
    }

    onClosing: {
        if(settings.notify_background_app_running_on_close){
            settings.notify_background_app_running_on_close = false;
            systemTrayIcon.showMessage("App Running In Background!!!","You can access the app menu on system tray on task bar menu.")
        }
        appClosed = true
    }

    Component.onDestruction: {
        if(!app.trackerInfo.isIdle()){
            dbOps.updateLog(app.trackerInfo);
        }
    }

    Component.onCompleted: {
        console.log(app.scaleFactor,height,width)

        //console.log(SystemInformation.machineUniqueId)
        //console.log(Util.generateUuid())
        console.log("Settings Location: ",StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/settings.config")

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

            onStartTracking: {
                app.trackerInfo.changeStateTracking();
                view.push(trackPage);

                if(!app.trackerInfo.jobID){
                    app.trackerInfo.jobID = Util.generateUuid();
                    dbOps.startLog(app.trackerInfo);
                }
            }
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
                app.trackerInfo.tString = "Paused!!";
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
        visible: app.appClosed && !app.trackerInfo.isIdle()

        onChangeState: {
            if(app.trackerInfo.isRunning()){
                app.trackerInfo.changeStatePaused()
                systemTrayIcon.showMessage("Tracker Paused!!","You may find the app menu on the task bar icon or double click on the floating tracker to resume.");
                app.trackerInfo.tString = "Paused!!";
            }
            else if(app.trackerInfo.isPaused()){
                app.trackerInfo.changeStateTracking()
            }
            else{
                console.log(app.trackerInfo.state)
            }
        }
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
        location: StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/settings.config"

        // App First Time Flags;
        property bool notify_background_app_running_on_close: true

        //---------------------;
    }

    Images{
        id: images
    }

    /*
      -------------------------------------------------------
      ----------------------System Timer---------------------
      -------------------------------------------------------
      */

    Timer{
        id: tracker
        interval: 1000
        repeat: true
        running: app.trackerInfo.isRunning()

        onTriggered:{
            if(app.trackerInfo.trackedTime%60 == 0){
               dbOps.updateLog(app.trackerInfo)
            }

            app.trackerInfo.trackedTime += 1
            app.trackerInfo.tString = Util.computeTrackedReadableTimeString(app.trackerInfo.trackedTime)
        }
    }

    //TODO:
    Timer{
        id: dateChangeObserver

        interval: 60000
        repeat: true
        running: true

        onTriggered: {
            var datetime = new Date();

            if(Util.dateDifference(today,datetime)){
                console.log("Date Changed")
            }
        }
    }

    Timer{
        id: pauseFlash
        running: app.trackerInfo.isPaused()
        repeat: true
        interval: 3000

        onTriggered: {
            app.trackerInfo.tString = app.trackerInfo.tString === "Paused!!" ? Util.computeTrackedReadableTimeString(app.trackerInfo.trackedTime) : "Paused!!";
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
