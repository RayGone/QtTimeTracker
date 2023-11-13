import QtCore
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import 'qrc:/Templates/'

Page {
    id: mainPage

    header: ToolBar{
        Material.background: Material.color(Material.LightBlue,Material.Shade900)

        RowLayout {
            anchors.fill: parent

            //            Label {
            //                text: "Title"
            //                elide: Label.ElideRight
            //                font.pointSize: 25
            //                horizontalAlignment: Qt.AlignHCenter
            //                verticalAlignment: Qt.AlignVCenter
            //                Layout.fillWidth: true
            //            }

            ToolButton{
                text: "Start New Job"
                font.family: app.fontFamily

                onClicked: {
                    newJob.open()
                }

            }
        }


    }

    Drawer{
        id: newJob
        width: mainPage.width
        height: mainPage.height/2
        edge: Qt.TopEdge
        interactive: false
        clip: true

        Pane{
            anchors.fill: parent

            ColumnLayout{
                anchors.fill: parent

                Rectangle{
                    Layout.preferredHeight: 50 * app.scaleFactor
                    Layout.preferredWidth: parent.width
                    color: Material.color(Material.LightBlue,Material.Shade900)
                    radius: 40 * app.scaleFactor

                    RowLayout{
                        anchors.fill: parent
                        anchors.centerIn: parent
                        spacing: 5 * app.scaleFactor


                        Divider{
                            Layout.preferredWidth: 5 * app.scaleFactor
                            Layout.preferredHeight: 30 * app.scaleFactor
                        }

                        Image{
                            source: 'qrc:/Icons/jobs.png'
                            Layout.preferredWidth: 30 * app.scaleFactor
                            Layout.preferredHeight: 30 * app.scaleFactor
                            fillMode: Image.PreserveAspectFit
                            //anchors.verticalCenter: parent.verticalCenter
                        }

                        TextTemplate{
                            anchors.centerIn: parent
                            text: 'Start a new job'
                            font.bold: Font.Light
                            color:"white"
                        }
                    }
                }

                Divider{
                    Layout.preferredHeight: 15
                }

                TextField{
                    placeholderText: "Job Title"
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 30 * app.scaleFactor
                    Material.accent: app.primaryColor
                    maximumLength: 50
                }

                TextField{
                    placeholderText: "Job Description"
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 30 * app.scaleFactor
                    Material.accent: app.primaryColor
                    maximumLength: 250
                }


                Divider{
                    Layout.preferredHeight: 5
                }

                Item{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

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

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Button{
                        id: closeButton
                        text: 'Not Now'
                        anchors.right: parent.right
                        Material.background: 'red'
                        Layout.preferredHeight: startButton.height
                        contentItem: TextTemplate{
                            text: parent.text
                            color: '#ffffff'
                            font.pointSize: 10 * app.scaleFactor
                            padding:{
                                left: 5 * app.scaleFactor
                                right: 5 * app.scaleFactor
                                bottom: 1
                                top: 1
                            }
                        }

                        onClicked: {
                            newJob.close();
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

            }
        }
    }

    ColumnLayout{
        anchors.fill: parent
    }
}
