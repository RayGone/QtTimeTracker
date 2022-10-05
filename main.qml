import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.LocalStorage 2.15
import Qt.labs.settings 1.1
import Qt.labs.platform
import "../templates"

ApplicationWindow {
    id: main
    width: 150
    height: 150

    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width
    visible: true
    title: qsTr("Time Tracker")
    flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint
    color: "transparent"

    property var database
    property int state: 0 //0 means not tracking or stopped; 1 means tracking time; 2 means tracking but currently paused;
    property int tracked_time: 0
    property string tString: "Time Tracker"
    property real current_track_rowid: -1

    property alias settings: settings    
    readonly property alias trackerProgress: secondaryContent.progressBar
    readonly property alias workDescription: mainContent.workDescription
    readonly property alias alertMsg: mainContent.alertMsg

    Settings{
        id: settings
    }

    Images{
        id: images
    }

    onScreenChanged: {
        console.log(Screen.pixelDensity)
    }

    Component.onCompleted: {
        //console.log(Screen.width,Screen.height)
        var pos = JSON.parse(settings.value("window-position",false))

        if(pos){
            setX(pos.x)
            setY(pos.y)
        }else{
            setX(Screen.width - (width+20))
            setY(Screen.height - height*1.5)
        }

        database = LocalStorage.openDatabaseSync("TimeTracker", "1.0", "Database used by TimeTracker App to store data", 1000000);
        createDatabase()

        workDescription.text = settings.value("last-work-description",false) ? "Prev: "+settings.value("last-work-description") : "Work Description"
    }


    function createDatabase(){
        main.database.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                //tx.executeSql('DROP TABLE TimeTracks')
                tx.executeSql('CREATE TABLE IF NOT EXISTS TimeTracks(trackid INTEGER PRIMARY KEY AUTOINCREMENT, work TEXT, start TIMESTAMP, end TIMESTAMP, tracked_time INTEGER)');
            }
        )
        console.log('Database Initialized!!')
    }

    function insertStart(work_desc = 'Work Item'){
        if(!work_desc) work_desc = "Work Item"
        main.database.transaction(
                    function(tx){
                        tx.executeSql("INSERT INTO TimeTracks(work,start,end,tracked_time) VALUES (?,strftime('%s'),strftime('%s'),0)",[work_desc])

                        tx.executeSql("SELECT last_insert_rowid() as id")
                    })
    }

    function insertEnd(tracked_time = 1,work_desc){
        main.database.transaction(
                    function(tx){
                        var rs = tx.executeSql("SELECT trackid FROM TimeTracks ORDER BY trackid DESC LIMIT 1")
                        var id = rs.rows.item(0)['trackid']

                        tx.executeSql("UPDATE TimeTracks SET tracked_time = ?, work = ?, end = strftime('%s') WHERE trackid=?",[tracked_time,work_desc,id])
                    })
    }

    function saveTimeBeforeClose(){
        if(tracked_time)
        insertEnd(tracked_time,workDescription.text)
    }

    /*
      -------------------------------------------------------
      -----------------Visible Items Start-------------------
      -------------------------------------------------------
     */

    ReportView{
        id: reportview
    }

    WindowPeripheral{
        id: buttons

        width: main.width
        height: main.height
        visible: active

        onDisplayReportView: {
            reportview.visible = !reportview.visible
        }
    }

    TemplateBody{
        id: body

        width: main.width
        height: main.height
        anchors.centerIn: parent
        radius: width/2

        Main{
            id: mainContent
            anchors.fill: parent
            visible: !secondaryContent.visible
        }

        TrackerDisplay{
            id: secondaryContent

            diameter: mainContent.width
            visible: false

            MouseArea{
                anchors.fill: parent

                onClicked: {
                    secondaryContent.visible = false
                }
            }

            property int lineWidth: 10
            property int animationDuration: 1000
            property var colorList: [
                Material.color(Material.Grey,Material.Shade900),
                Material.color(Material.Grey,Material.Shade100),
                Material.color(Material.Green,Material.Shade900),
                Material.color(Material.Red,Material.Shade900),
                Material.color(Material.DeepPurple,Material.Shade900),
                Material.color(Material.Yellow,Material.Shade900),
                Material.color(Material.Indigo,Material.Shade900),
                Material.color(Material.Lime,Material.Shade900),
            ]
        }
    }

    /*
      -------------------------------------------------------
      -----------------Visible Items End---------------------
      -------------------------------------------------------
     */

    onActiveChanged: {
        if(active){
            showNormal()
            body.opacity = 1
        }else{
            trigger.repeat = true
            body.opacity = 0.4

            if(main.state){
                secondaryContent.visible = true
            }
        }
    }

    Timer{
        id: trigger
        running: !active
        interval: 120000
        repeat: true
        onTriggered: {
            if(body.opacity === 04) body.opacity = 0.2;
            else {
                if(!tracked_time) showMinimized();
                console.log('App Inactive: Minimizing');
                repeat = false
            }
        }
    }

    Timer{
        id: tracker
        interval: 1000
        repeat: true
        running: false

        property double v: 0
        onTriggered:{
            main.tracked_time += 1


            tString = computeTrackedReadableTimeString()
            alertMsg.text = tString

            if(tracked_time == 1 || tracked_time%20 === 0)
                trackerProgress.nextStep((tracked_time%3600)/3600)
            //v+=0.1
            //trackerProgress.nextStep(v)

            if(tracked_time%60 === 0) insertEnd(tracked_time,workDescription.text)
        }
    }

    Timer{
        id: pauseFlash
        running: main.state === 2
        repeat: true
        interval: 3000

        onTriggered: {
            var tmp = main.tString === "Paused" ? computeTrackedReadableTimeString() : "Paused"
            alertMsg.text = tString = tmp
        }
    }

    function computeTrackedReadableTimeString(){
        var m = parseInt(tracked_time/60)
        var s = tracked_time - m*60
        var h = parseInt(m/60)
        m = m - h*60
        return (h<10? "0"+h : h) + ":" + (m<10? "0"+m : m) + ":" + (s<10 ? "0"+s : s)
    }
}
