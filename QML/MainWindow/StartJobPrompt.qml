import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import "qrc:/QML/Controls"

Drawer{
    id: newJob
    edge: Qt.TopEdge
    interactive: false
    clip: true
    dragMargin: 0

    signal start()
    property string title: jobTitle.text
    property string description: jobDesc.text

    function keyEnterPressedHandler(event){
        if(event.key + Qt.EnterKeyReturn=== Qt.Key_Enter) startButton.clicked()
    }

    Pane{
        width: parent.width
        height: parent.height
        bottomPadding: 0
        topPadding: 5
        bottomInset: 5

        //Material.background: 'transparent'
        //Material.background: Color.transparent(Qt.lighter(app.primaryColor),0.3)

        ScrollView{
            width: parent.width
            height: parent.height
            clip: false

            ColumnLayout{
                id: contentColumn
                width: parent.width

                HeadTitle{
                    id: htitle
                }

                Divider{
                    id: item1
                    Layout.preferredHeight: 10 * app.scaleFactor
                }

                TextTemplate{
                    id: item2
                    text: "Date: " + app.today.toLocaleDateString()
                }

                TextField{
                    id: jobTitle
                    placeholderText: "Job Title"
                    placeholderTextColor: focus ? app.primaryColor : Color.transparent(app.primaryColor,0.4)
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 35 * app.scaleFactor
                    Material.accent: app.primaryColor
                    maximumLength: 50

                    Keys.onPressed: keyEnterPressedHandler(event)
                }

                TextField{
                    id: jobDesc
                    placeholderText: "Job Description"
                    placeholderTextColor: focus ? app.primaryColor : Color.transparent(app.primaryColor,0.4)
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 35 * app.scaleFactor
                    Material.accent: app.primaryColor
                    Material.foreground: app.primaryColor
                    maximumLength: 250

                    Keys.onPressed: keyEnterPressedHandler(event)
                }

                Item{
                    id: item5
                    Layout.fillWidth: true
                    Layout.preferredHeight: startButton.height + 10

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
                            if(jobTitle.text.length < 4){
                                app.systemTrayIcon.showMessage("Missing Field","Job Title is required field.\nText length must be 4 or more characters.")
                            }
                            else{
                                newJob.close()
                                start()
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
                            app.trackerInfo.jobTitle = ''
                            app.trackerInfo.jobDesc = ''
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

            }
        }
    }
}
