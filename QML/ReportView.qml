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

    property bool groupby: false
    property date fromDate: app.today
    property date toDate: app.today


    Component.onCompleted: {
        console.log("ReportView Pushed To Stack!!");
        var data = app.dbOps.getReport();
        if(data.length){
            toDate = data[0]['work_date'];
            fromDate = data[data.length-1]['work_date'];
            workReports.tableModel = data;
        }
        setTotalTime(data)
    }

    function setTotalTime(data){
        var total_time = 0;
        for(var i in data){
            total_time += data[i]['logged_time']
        }
       totalLog.text =  Util.readableTimeString(total_time)
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

    Column{
        id: mainCol
        width: parent.width
        height: parent.height

        Divider{
            width: parent.width
            height: 1 * app.scaleFactor
        }

        CheckBox{
            id: groupByJob
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
            id: row1
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
                color: (datePickerPopup.changeDate === datePickerPopup.changeFromDate && datePickerPopup.visible) ? app.secondaryColor : app.primaryColor
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

                    cursorShape: Qt.PointingHandCursor
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
                color: (datePickerPopup.changeDate === datePickerPopup.changeToDate && datePickerPopup.visible) ? app.secondaryColor : app.primaryColor
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

                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Row{
            id: row2
            width: parent.width
            spacing: 5 * app.scaleFactor

            TextTemplate{
                font.pointSize: 8 * app.scaleFactor
                text: 'Total Logged Hours: '
                horizontalAlignment: Text.AlignLeft
                leftPadding: 15 * app.scaleFactor
            }


            TextTemplate{
                id: totalLog
                font.pointSize: 8 * app.scaleFactor
                text: 'X hours'
                horizontalAlignment: Text.AlignLeft
            }
        }

        Divider{
            width: parent.width
            height: 5 * app.scaleFactor
        }

        Item{
            id: row3
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

                //RoundButton{
                //    id: saveBtn
                //    padding: 5
                //    anchors.right: parent.right
                //    height: parent.height*1.5
                //    width: height

                //    text: 'Save'
                //    anchors.verticalCenter: parent.verticalCenter
                //    Material.background: app.primaryColor

                //    contentItem: TextTemplate{
                //        text: parent.text
                //        font.pointSize: 7 * app.scaleFactor
                //        color: 'white'
                //    }

                //    onClicked: {
                //        saveFileDrawer.open()
                //    }
                //}
            }
        }

        Divider{
            width: parent.width
            height: 5 * app.scaleFactor
        }

        HistoryTable{
            id: workReports
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20 * app.scaleFactor
            height: parent.height - (row1.height+row2.height+row3.height+ groupByJob.height+ 18*app.scaleFactor)
            spacing: 3 * app.scaleFactor
            showReplay: true

            tableModel: []
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
                        systemTrayIcon.showMessage("Invalid Date Selection!!","Please select a date before the date set on To Date: "+Util.getDateString(reportView.toDate));
                         datePicker.selectedDate = reportView.fromDate
                        return;
                    }

                    reportView.fromDate = datePicker.selectedDate
                }else{
                    if(reportView.fromDate > datePicker.selectedDate){
                        systemTrayIcon.showMessage("Invalid Date Selection!!","Please select a date after the date set on From Date: "+Util.getDateString(reportView.fromDate));
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
}
