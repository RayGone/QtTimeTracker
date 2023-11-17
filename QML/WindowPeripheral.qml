import QtQuick 2.15
import "qrc:/QML/Controls"

Item{
    id: buttons

    signal displayReportView()

    MoveWindow{
        id: moveWindow
        width: 20
        height: 20
        radius: width/2
        imgSrc: "../Icons/move.png" //images.move
    }

    MinimizeWindow{
        id: minimizeWindow

        width: 20
        height: 20
        radius: width/2
        imgSrc: '../Icons/minimize.png'
    }

    CloseWindow{
        id: closeWindow

        width: 20
        height: 20
        radius: width/2
        imgSrc: '../Icons/close.png'
    }

    DumpReport{
        id: dumpTimeSheet

        width: 20
        height: 20
        radius: width/2
        imgSrc: '../Icons/dump.png'

        onFileSaved: {
            console.log("File Saved")
            displayStatus.msg = "File Saved!!!"
            displayStatus.start()
        }

        onDumpReport: {
            displayReportView()
        }

        Timer{
            id: displayStatus
            running: false
            repeat: !main.state || main.state === 0
            interval: 2000
            triggeredOnStart: true

            property int sp: 0
            property string msg: ""

            onTriggered: {
                if(sp === 0){
                    console.log("Step 1")
                    alertMsg.text = msg
                    if(repeat) sp = 1
                    else sp = 0
                }

                else if(sp === 1){
                    console.log("Step 2")
                    alertMsg.text = "Start Tracking"
                    displayStatus.stop()
                    sp = 0
                }
            }
        }
    }
}
