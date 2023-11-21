import QtCore
import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels
import QtQuick.Controls.Material 2.15
import QtQuick.Shapes 1.3
import Qt.labs.platform

import "qrc:/QML/Controls"
import "qrc:/Utilities/Utils.js" as Util

Page{
    id: reportView

    signal back()

    header: ToolBar{
        Material.background: app.primaryColor
        Row{
            height: parent.height
            width: parent.width
            RoundButton{
                id: backBtn
                icon.source: "qrc:/Icons/back.png"
                icon.color: 'transparent'
                Material.background: app.primaryColor

                onClicked: back()
            }

            HeadTitle{
                width: parent.width - 50 * app.scaleFactor
                height: parent.height
                textElem.text: 'Work Reports'
            }
        }
    }

    property bool groupby: true
    property date fromDate: app.today
    property date toDate: app.today

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

    Item{
        width: parent.width
        height: parent.height * 0.35
        visible: false

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
                                id: filterBtn_
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

    Column{
        width: parent.width
        height: parent.height

        Divider{
            width: parent.width
            height: 1 * app.scaleFactor
        }

        CheckBox{
            id: groupByJob0
            text: "Group By Job Title"
            Material.accent: app.primaryColor
            checked: groupby
            leftPadding: 20 * app.scaleFactor

            contentItem: TextTemplate{
                leftPadding: 20 * app.scaleFactor
                text: parent.text
                font.pointSize: 8 * app.scaleFactor
            }

            onToggled: {
                groupby = checked
            }

        }

        Row{
            id: row2_1
            width: parent.width
            spacing: 10 * app.scaleFactor

            TextTemplate{
                font.pointSize: 8 * app.scaleFactor
                text: 'Showing Logs From:'
                horizontalAlignment: Text.AlignLeft
                leftPadding: 15 * app.scaleFactor
            }

            Rectangle{
                width: fromDateText.width + 20
                height: parent.height
                color: app.primaryColor
                radius: 20* app.scaleFactor
                TextTemplate{
                    id: fromDateText
                    anchors.centerIn: parent
                    font.pointSize: 8 * app.scaleFactor
                    text: Util.getDateString(reportView.fromDate)
                    font.family: app.secondaryFontFamily
                    font.bold: Font.DemiBold
                    color: 'white'
                    style: Text.Outline
                    styleColor: app.secondaryColor
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        datePickerPopup.open()
                        datePicker.selectedDate = fromDate
                        datePickerPopup.changeDate = datePickerPopup.changeFromDate
                    }
                }
            }

            TextTemplate{
                font.pointSize: 8 * app.scaleFactor
                text: 'To:'
                horizontalAlignment: Text.AlignLeft
            }

            Rectangle{
                width: toDateText.width + 20
                height: parent.height
                color: app.primaryColor
                radius: 20* app.scaleFactor
                TextTemplate{
                    id: toDateText
                    anchors.centerIn: parent
                    font.pointSize: 8 * app.scaleFactor
                    text: Util.getDateString(reportView.toDate)
                    font.family: app.secondaryFontFamily
                    font.bold: Font.DemiBold
                    color: 'white'
                    style: Text.Outline
                    styleColor: app.secondaryColor
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        datePickerPopup.open()
                        datePicker.selectedDate = reportView.toDate
                        datePickerPopup.changeDate = datePickerPopup.changeToDate
                    }
                }
            }
        }

        TextTemplate{
            width: parent.width
            font.pointSize: 8 * app.scaleFactor
            text: 'Total Logged Hours: X hours'
            horizontalAlignment: Text.AlignLeft
            leftPadding: 15 * app.scaleFactor
        }

        Divider{
            width: parent.width
            height: 5 * app.scaleFactor
        }

        Item{
            id: row1
            width: parent.width
            height: 30 * app.scaleFactor
            Rectangle{
                width: parent.width - 20
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                color: Color.transparent(app.primaryColor,0.5)
                radius: 5 * app.scaleFactor

                TextTemplate{
                    padding: 5
                    font.pointSize: 8 * app.scaleFactor
                    text: 'Work History'
                    anchors.verticalCenter: parent.verticalCenter
                }

                RoundButton{
                    id: saveBtn
                    padding: 5
                    anchors.right: filterBtn.left

                    text: 'Save'
                    anchors.verticalCenter: parent.verticalCenter
                    Material.background: app.primaryColor

                    contentItem: TextTemplate{
                        text: parent.text
                        font.pointSize: 7 * app.scaleFactor
                        color: 'white'
                    }

                    onClicked: {
                        saveFileDrawer.open()
                    }
                }

                RoundButton{
                    id: filterBtn
                    padding: 5
                    anchors.right: parent.right
                    text: 'Filter'
                    anchors.verticalCenter: parent.verticalCenter
                    Material.background: app.primaryColor

                    contentItem: TextTemplate{
                        text: parent.text
                        font.pointSize: 7 * app.scaleFactor
                        color: 'white'
                    }

                    onClicked: {
                        filterDrawer.open()
                    }
                }
            }
        }

        Divider{
            width: parent.width
            height: 5 * app.scaleFactor
        }

        HistoryTable{
            id: workReports
            width: parent.width
            height: parent.height
            spacing: 3 * app.scaleFactor
            showReplay: true

            tableModel: []//app.dbOps.
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

    Popup{
        id: datePickerPopup
        modal: true
        anchors.centerIn: parent
        height: datePicker.height + 10
        width: datePicker.width + 10

        readonly property int changeFromDate: 1
        readonly property int changeToDate: 2
        property int changeDate: changeFromDate

        background: Rectangle{
            height: datePickerPopup.height
            width: datePickerPopup.width
            color: 'transparent'
        }

        DatePicker{
            id: datePicker
            anchors.centerIn: parent
            //Don't Set height and width - instead set boxWidth: and boxHeight:
            onDatePicked: {
                if(datePickerPopup.changeDate === datePickerPopup.changeFromDate){
                    if(reportView.toDate < datePicker.selectedDate){
                        systemTrayIcon.showMessage("Invalid Date Selection!!","Please select date before "+Util.getDateString(reportView.toDate));
                         datePicker.selectedDate = reportView.fromDate
                        return;
                    }

                    reportView.fromDate = datePicker.selectedDate
                }else{
                    if(reportView.fromDate > datePicker.selectedDate){
                        systemTrayIcon.showMessage("Invalid Date Selection!!","Please select date after "+Util.getDateString(reportView.fromDate));
                         datePicker.selectedDate = reportView.toDate
                        return;
                    }
                    reportView.toDate = datePicker.selectedDate
                }
                datePickerPopup.close()
            }
        }
    }

    Drawer{
        id: saveFileDrawer
        edge: Qt.BottomEdge
        clip: true

        width: parent.width
        height: parent.height/1.5
    }

    Drawer{
        id: filterDrawer
        edge: Qt.BottomEdge
        clip: true

        width: parent.width
        height: parent.height/1.5

        Pane{
            anchors.fill: parent

            Column{
                anchors.fill: parent

                TextTemplate{
                    text: "Filters"
                    font.bold: true
                }
                ToolSeparator{
                    width: parent.width
                    orientation: Qt.Horizontal
                }

                CheckBox{
                    id: groupByJob
                    text: "Group By Job Title"
                    Material.accent: app.primaryColor
                    checked: groupby

                    contentItem: TextTemplate{
                        leftPadding: 20 * app.scaleFactor
                        text: parent.text
                        font.pointSize: 8 * app.scaleFactor
                    }

                    onToggled: {
                        groupby = checked
                    }

                }

                Button{
                    id: startButton
                    text: 'Go'
                    Material.background: app.primaryColor
                    contentItem: TextTemplate{
                        text: parent.text
                        color: '#ffffff'
                        padding:{
                            left: 5 * app.scaleFactor
                            right: 5 * app.scaleFactor
                            bottom: 1
                            top: 1
                        }
                    }

                    onClicked: {
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
