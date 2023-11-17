import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels
import QtQuick.Controls.Material 2.15
import QtQuick.Shapes 1.3
import Qt.labs.platform

import "qrc:/QML/Controls"

Page{
    id: reportView

    signal back()

//    width: app.width * 4.5
//    height: app.height * 3
//    maximumHeight: height
//    maximumWidth: width
//    minimumHeight: height
//    minimumWidth: width
//   flags: Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    property bool groupby: app.settings.value("filter-groupby",false)

    function setWindowPosition(){
        if(app.x - width > 10)
            setX(app.x - width)
        else
            setX(app.x + app.width)

        if(app.y - height > 10)
            setY(app.y - height)
        else
            setY(app.y + app.height)
    }

    Component.onCompleted: {
        console.log("ReportView Pushed To Stack!!");
    }

    onVisibleChanged: {
        if(visible){
            setWindowPosition()
            //-----------------

            defaultData()
        }
    }

//    Rectangle {
//        // background
//        anchors.fill: parent
//        color: Material.color(Material.Blue,Material.Shade600)
//    }


    function defaultData(){
        if(groupby)
            app.db.filterByWork_Date(app.settings.value("filter-limit",'14'))
        else
            app.db.filterByDate(app.settings.value("filter-limit",'14'))
    }

    FolderDialog{
        id: fd

        onAccepted: {
            console.log(folder)

            app.settings.setValue("report-dump-locaton",folder.toString())
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
                    color: Material.color(Material.Blue,Material.Shade800)

                    RoundButton{
                        id: backBtn
                        icon.source: "qrc:/Icons/back.png"
                        icon.color: 'transparent'
                        anchors.verticalCenter: parent.verticalCenter
                        Material.background: app.primaryColor

                        onClicked: back()
                    }

                    HeadTitle{
                        anchors.left: backBtn.right
                        width: row1.width - 50 * app.scaleFactor
                        height: row1.height - 6 * app.scaleFactor
                        textElem.text: 'Work Reports'
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }


                Rectangle{
                    id: row2
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
                                text: app.settings.value("report-dump-locaton","file:///D:").replace("file:///","")
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

                                var filename = app.settings.value('report-dump-locaton',"file:///D:") + "/Work_Log_"+today+".csv"
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
                                    path.text = app.settings.value('report-dump-locaton',"file:///D:").replace("file:///","")
                                }
                            }
                        }
                    }
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
                                    color: groupby ? 'green' : "gray"
                                    width: wdFilterLabel.width + 15
                                    height: parent.height
                                    border.color: groupby ? 'white' : Material.color(Material.Blue,Material.Shade900)
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
                                            groupby = !groupby
                                            app.settings.setValue("filter-groupby",groupby)
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
                                        text: app.settings.value("filter-limit",'14')
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 36
                                        clip: true
                                        renderType: TextInput.NativeRendering
                                        anchors.centerIn: parent
                                        color: 'black'
                                        validator: IntValidator{bottom: 1; top: 99999;}
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

                                        app.settings.setValue("filter-limit",limit)
                                        defaultData()
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
