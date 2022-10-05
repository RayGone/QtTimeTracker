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

    function defaultData(){
        main.database.transaction(
            function(tx){
                // var rs = tx.executeSql("SELECT trackid as SN,work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Started_At, date(datetime(datetime(end,'unixepoch'),'localtime')) as Ended_At, tracked_time as Tracked_Seconds FROM TimeTracks")
                var query = "
                    SELECT work, date(datetime(datetime(start,'unixepoch'),'localtime')) as date, sum(tracked_time)/60 as minutes
                    FROM TimeTracks
                    WHERE datetime(datetime(start,'unixepoch'),'localtime') > datetime('now','-14 day','localtime')
                    GROUP BY work, date(datetime(datetime(start,'unixepoch'),'localtime'))
                    ORDER BY start
                ";
                var rs = tx.executeSql(query)

                tableModel.clear()
                tableModel.appendRow({work:"Work Description",date:"Date",hours:'Hours',minutes:"Minutes"})
                for(var i=0;i<rs.rows.length;i++){
                    var item = rs.rows.item(i)
                    item['hours'] = parseInt(item['minutes']/60)
                    item['minutes'] = item['minutes'] - item['hours']*60
                    tableModel.appendRow(item)
                }
            })
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
                                var csv_string = ""
                                for(var i=0;i<tableModel.rowCount;i++){
                                    csv_string +=  Object.values(tableModel.getRow(i)).join(",") + "\n"
                                }
                                var filename = main.settings.value('report-dump-locaton',"file:///D:") + "/Work Log.csv"
                                saveFile(filename,csv_string)
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
                }

                RoundButton{
                    text: "heelo"
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

            delegate: Rectangle {
                implicitWidth: reportView.width/4
                implicitHeight: 20
                border.width: 1
                color: Material.color(Material.Blue,Material.Shade500)

                Text {
                    text: display
                    anchors.centerIn: parent
                    //font.weight: display === 'header' ? font.Bold : font.Normal
                }
            }
        }

    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, true);
        request.send(text);
        return request.status;
    }
}
