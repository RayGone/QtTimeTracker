import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels
import QtQuick.Controls.Material 2.15
import QtQuick.Shapes 1.3
import Qt.labs.platform


Window{
    id: reportView

    width: main.width * 4.5
    height: main.height * 3
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width

    property bool groupby: false

    function setWindowPosition(){
        if(main.x - width > 10)
            setX(main.x - width)
        else
            setX(main.x + main.width)

        if(main.y - height > 10)
            setY(main.y - height)
        else
            setY(main.y + main.height)
    }

    onVisibleChanged: {
        if(visible){
            setWindowPosition()
            //-----------------

            defaultData()
        }
    }

    Rectangle {
        // background
        anchors.fill: parent
        color: Material.color(Material.Blue,Material.Shade600)
    }

    function filterByDate(limit=14){
        main.database.transaction(
            function(tx){
                // var rs = tx.executeSql("SELECT trackid as SN,work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Started_At, date(datetime(datetime(end,'unixepoch'),'localtime')) as Ended_At, tracked_time as Tracked_Seconds FROM TimeTracks")
                var query = "
                    SELECT work, date(datetime(datetime(start,'unixepoch'),'localtime')) as date, sum(CAST(tracked_time AS REAL))/60 as minutes
                    FROM TimeTracks
                    WHERE datetime(datetime(start,'unixepoch'),'localtime') > datetime('now','start of day',?,'localtime')
                    GROUP BY work, date(datetime(datetime(start,'unixepoch'),'localtime'))
                    ORDER BY start
                ";
                limit = "-"+(limit-1)+" day"
                var rs = tx.executeSql(query,[limit])

                tableModel.clear()
                tableModel.appendRow({work:"<b>Work Description</b>",date:"<b>Date</b>",hours:'<b>Hours</b>',minutes:"<b>Minutes</b>"})

                var total = 0
                for(var i=0;i<rs.rows.length;i++){
                    var item = rs.rows.item(i)
                    total += parseInt(Math.ceil(item['minutes']))
                    item['hours'] = parseInt(parseInt(Math.ceil(item['minutes']))/60)
                    item['minutes'] = parseInt(Math.ceil(item['minutes']) - item['hours']*60)
                    tableModel.appendRow(item)
                }

                var summary_string = ""
                if(rs.rows.length > 0){
                    var from = rs.rows.item(0)['date']
                    var to = rs.rows.item(rs.rows.length-1)['date']

                    summary_string =      "Showing Log From&nbsp;&nbsp;&nbsp;: <b><i><u>"+from+"</u></i></b> to : <b><i><u>"+ to+"</u></i></b>"
                    summary_string += "<br>Total Worked Hours&nbsp;: <b><i><u>"+parseInt(total/60)+"hr"+" "+(total%60)+"min</u></i></b>"

                    console.log(parseInt(total/60)+"hr"+" "+(total%60)+"min")
                }else{
                    summary_string = "No logs to show.
                            Start tracking."

                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                }

                logsummary.text = summary_string
            });

    }

    function defaultData(){
        filterByDate()
    }

    FolderDialog{
        id: fd

        onAccepted: {
            console.log(folder)

            main.settings.setValue("report-dump-locaton",folder.toString())
            path.text = folder.toString().replace("file:///","")
        }
    }

    FileDialog{
        id: filedialog
        fileMode: FileDialog.SaveFile
    }

    TableModel {
        id: tableModel

        TableModelColumn { display: "work" }
        TableModelColumn { display: "date" }
        TableModelColumn { display: "hours" }
        TableModelColumn { display: "minutes" }

    }

    Column{
        anchors.fill: parent

        Item{
            width: parent.width
            height: parent.height * 0.35

            Rectangle{
                anchors.fill: parent
                gradient: LinearGradient {
                    GradientStop { position: 0.0; color: Material.color(Material.Blue,Material.Shade600) }
                    GradientStop { position: 0.5; color: Material.color(Material.Blue,Material.Shade700) }
                    GradientStop { position: 1.0; color: Material.color(Material.Blue,Material.Shade600) }
                }
            }

            Column{
                anchors.fill: parent

                Rectangle{
                    id: row1
                    height: parent.height/3
                    width: parent.width
                    color: Material.color(Material.Blue,Material.Shade900)

                    Row{
                        spacing: 5
                        anchors.centerIn: parent

                        Item{
                            height: 10
                            width: 10
                        }

                        Text{
                            text: "Current Location : "
                            anchors.verticalCenter: parent.verticalCenter
                            color: 'white'
                        }

                        Rectangle{
                            height: path.height + 6
                            width: path.width + 20
                            color: 'white'
                            radius: 5
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            Material.elevation: 5

                            TextInput{
                                id: path
                                anchors.centerIn: parent
                                text: main.settings.value("report-dump-locaton","file:///D:").replace("file:///","")
                                font.pixelSize: 14
                                //font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                width: reportView.width/2.4
                            }
                        }

                        Item{
                            height: 10
                            width: 10
                        }

                        Button{
                            id: changePath
                            text: "Change Path"
                            Material.accent: Material.color(Material.Blue,Material.Shade700)
                            Material.background: Material.color(Material.Blue,Material.Shade700)
                            height: 35
                            width: 90

                            contentItem: Text{
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.bold: true
                            }

                            onClicked: {
                                fd.open()
                            }
                        }

                        ToolSeparator{
                            orientation: Qt.Vertical
                            height: parent.height
                        }

                        Button{
                            id: saveReport
                            text: "Save Log"
                            Material.accent: Material.color(Material.Blue,Material.Shade700)
                            Material.background: Material.color(Material.Blue,Material.Shade700)
                            height: 35
                            width: 90

                            contentItem: Text{
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.bold: true
                            }

                            onClicked: {
                                var date = new Date()
                                var today = date.getFullYear()+""+(date.getMonth()<9?"0"+(date.getMonth()+1):(date.getMonth()+1))+""+(date.getDate()<=9?"0"+date.getDate():date.getDate())

                                var csv_string = ""
                                var th = 0
                                var tm = 0
                                for(var i=0;i<tableModel.rowCount;i++){
                                    csv_string +=  Object.values(tableModel.getRow(i)).join(",") + "\n"
                                    if(i>0){
                                        th += parseInt(tableModel.getRow(i)["hours"])
                                        tm += parseInt(tableModel.getRow(i)["minutes"])
                                    }
                                }

                                csv_string = csv_string.split("<b>").join("")
                                csv_string = csv_string.split("</b>").join("")

                                th += parseInt(tm/60)
                                tm -= (parseInt(tm/60)*60)
                                csv_string += "Total: ,"+th+"hr "+tm+"min,,"

                                var filename = main.settings.value('report-dump-locaton',"file:///D:") + "/Work_Log_"+today+".csv"
                                try{
                                    saveFile(filename,csv_string,displayState)
                                }catch(e){
                                    console.log(e,"--")
                                }
                            }

                            function displayState(){
                                tr.start()
                                path.text = "File Saved Successfully!!!"
                            }

                            Timer{
                                id: tr
                                repeat: false
                                interval: 3000

                                property string str: ""
                                onTriggered: {
                                    path.text = main.settings.value('report-dump-locaton',"file:///D:").replace("file:///","")
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: row2
                    height: parent.height/3
                    width: parent.width
                    color: Material.color(Material.Blue,Material.Shade800)
                }

                Rectangle{
                    id: row3
                    height: parent.height/3
                    width: parent.width
                    color: Material.color(Material.Blue,Material.Shade700)

                    Row{
                        width: parent.width
                        height: parent.height
                        spacing: 5

                        Item{
                            height: 10
                            width: 10
                        }

                        Column{
                            height: parent.height
                            width: parent.width * 0.4

                            spacing: 2

                            Text{
                                text: "Summary:"
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.bold: true
                                style: Text.Sunken
                                styleColor: "green"
                                textFormat: Text.StyledText
                            }

                            Text{
                                id: logsummary
                                text: "Showing Data From A to B <br> Total Hours: X hours"
                                color: "white"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                style: Text.Sunken
                                styleColor: "black"
                                textFormat: Text.StyledText
                            }

                        }

                        ToolSeparator{
                            orientation: Qt.Vertical
                            height: parent.height
                        }


                        Column{
                            height: parent.height
                            width: parent.width * 0.5

                            spacing: 2

                            Row{
                                width: parent.width
                                height: parent.height * 0.334
                                spacing: 5

                                Text{
                                    text: "Group By: "
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    style: Text.Sunken
                                    styleColor: "black"
                                    textFormat: Text.StyledText
                                    font.bold: true
                                }

                                Rectangle{
                                    color:"gray"
                                    width: wdFilterLabel.width + 15
                                    height: parent.height
                                    border.color: Material.color(Material.Blue,Material.Shade900)
                                    border.width: 1
                                    radius: 5
                                    Text{
                                        id: wdFilterLabel
                                        text: "Work Description"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                        style: Text.Sunken
                                        styleColor: "black"
                                        textFormat: Text.StyledText
                                        anchors.centerIn:  parent
                                        color:'white'
                                        font.pixelSize: 10
                                    }


                                    MouseArea{
                                        anchors.fill: parent
                                        onClicked: {
                                            if(!groupby){
                                                wdFilterLabel.parent.border.color = 'white'
                                                wdFilterLabel.parent.color = 'green'
                                            }else{
                                                wdFilterLabel.parent.border.color = Material.color(Material.Blue,Material.Shade900)
                                                wdFilterLabel.parent.color = 'gray'
                                            }
                                            groupby = !groupby
                                        }
                                    }
                                }
                            }

                            Row{
                                width: parent.width
                                height: parent.height * 0.666

                                Text{
                                    text: "Show log of "
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    style: Text.Sunken
                                    styleColor: "black"
                                    textFormat: Text.StyledText
                                    color:'white'
                                    font.bold: true
                                }

                                Item{
                                    width: 10
                                    height: 10
                                }

                                Rectangle{
                                    height: dayLimit.height + 5
                                    width: dayLimit.width + 10
                                    border.color: "black"

                                    TextInput{
                                        id: dayLimit
                                        inputMethodHints: Qt.ImhPreferNumbers | Qt.ImhNoPredictiveText
                                        text: "14"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 36
                                        clip: true
                                        renderType: TextInput.NativeRendering
                                        anchors.centerIn: parent
                                        color: 'black'
                                    }

                                }

                                Item{
                                    width: 10
                                    height: 10
                                }

                                Text{
                                    text: "days"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    style: Text.Sunken
                                    styleColor: "black"
                                    textFormat: Text.StyledText
                                    color:'white'
                                    font.bold: true
                                }

                                Item{
                                    width: 40
                                    height: 10
                                }

                                Button{
                                    id: filterBtn
                                    text: "Filter"
                                    Material.accent: Material.color(Material.Blue,Material.Shade700)
                                    Material.background: Material.color(Material.Blue,Material.Shade900)
                                    height: 35
                                    width: 90

                                    contentItem: Text{
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                        font.bold: true
                                    }

                                    onClicked: {
                                        if(dayLimit.text.length == 0) {
                                            dayLimit.text = '14'
                                        }
                                        var limit = parseInt(dayLimit.text)
                                        if(limit<0) limit *= -1
                                        if(limit===0) limit = 1

                                        dayLimit.text = limit
                                        filterByDate(limit)
                                    }
                                }
                            }
                        }

                    }
                }

                RoundButton{
                    text: "hello"
                    height: 20
                    width: 20
                    radius: 10
                    visible: false
                    contentItem: Rectangle{
                        anchors.fill: parent
                        border.width: 3
                        radius: width/2
                        Image{
                            anchors.fill: parent
                            source: "../Icons/minimize.png"
                        }
                    }
                }

            }
        }

        TableView{
            id: tableView
            width: parent.width
            height: parent.height * 0.65
            model: tableModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar{}

            delegate: Rectangle {
                implicitWidth: reportView.width/4
                implicitHeight: 20
                border.width: 1
                color: Material.color(Material.Blue,Material.Shade500)

                Text {
                    text: display
                    anchors.centerIn: parent
                    color: "white"
                    style: Text.Raised
                    styleColor: "black"
                    textFormat: Text.StyledText
                    //font.weight: display === 'header' ? font.Bold : font.Normal
                }
            }
        }

    }

    function saveFile(fileUrl, text, callback) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, true);
        request.onreadystatechange = function(){
            if(request.readyState == request.DONE){
                callback()
            }
        }
        request.send(text);

        return request.status;
    }
}
