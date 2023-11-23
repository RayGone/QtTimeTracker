import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle{
    id: calendar
    color: app.primaryColor
    radius: 20
    height: layout.height + 20
    width: layout.width + 20

    property int month
    property int year

    property int boxHeight: 25
    property int boxWidth: 25

    property date selectedDate: app.today
    property color textColor: 'white'

    signal datePicked();

    onSelectedDateChanged: {
        calendar.month = selectedDate.getMonth()
        calendar.year = selectedDate.getFullYear()
    }

    ColumnLayout{
        id: layout
        anchors.centerIn: parent

        RowLayout{
            id: yearMonthRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 5 * app.scaleFactor

            ToolButton{
                text: "<<"
                onClicked: {
                    var month = dateGrid.month === 0 ? 11 : dateGrid.month - 1
                    if(month === 11) dateGrid.year -=1
                    dateGrid.month = month
                }
            }

            TextTemplate{
                text: (dateGrid.month+1) + "/" + dateGrid.year
                color: textColor
            }

            ToolButton{
                text: ">>"
                onClicked: {
                    var month = dateGrid.month === 11 ? 0 : dateGrid.month + 1
                    if(month === 0) dateGrid.year +=1
                    dateGrid.month = month
                }
            }
        }

        RowLayout{
            id: weekRow
            Layout.fillWidth: true
            DayOfWeekRow{
                Layout.fillWidth: true

                delegate: TextTemplate{
                    text: model.shortName
                    font.pointSize: 7 * app.scaleFactor
                    color: textColor
                }
            }
        }

        MonthGrid{
            id: dateGrid

            height: calendar.boxHeight * 7
            width: calendar.boxWidth * 7
            month: calendar.month
            year: calendar.year

            delegate: Rectangle{
                height: calendar.boxHeight
                width: calendar.boxWidth
                opacity: model.month === dateGrid.month ? 1 : 0
                color: (model.day === selectedDate.getDate() && model.month === selectedDate.getMonth()) ? app.secondaryColor : 'transparent'
                border.color: (model.day === selectedDate.getDate() && model.month === selectedDate.getMonth()) ? Color.transparent(app.secondaryColor,0.5) : 'transparent'
                border.width: 2
                radius: width
                TextTemplate{
                    anchors.centerIn: parent
                    text: model.day
                    font.pointSize: 7 * app.scaleFactor
                    color: textColor
                }

                MouseArea{
                    anchors.fill: parent

                    onClicked: {
                        if(model.month === dateGrid.month){
                            calendar.selectedDate = model.date
                            datePicked()
                        }
                    }
                }
            }
        }
    }
}
