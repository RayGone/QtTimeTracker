import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item{
    id: tracker
    anchors.fill: parent
    visible: !main.active && main.tracked_time

    Text {
        id: timeDisplay
        text: qsTr(main.tString)
        font.pointSize: 17
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.weight: 700
        style: Text.Outline
        styleColor: "blue"
    }


    // Properties Related to Canvas / Progress Bar
    // This is taken from https://github.com/rafzby/circular-progressbar
    // -------------------------------------------------------------------
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

    property int diameter: 0

    property int colorIndex: 0
    property color primaryColor: colorList[0]
    property color secondaryColor: colorList[1]
    readonly property alias progressBar: progressBar

    Canvas {
           id: progressBar

           property real degree: 0
           property int prevProg: 0

           anchors.fill: parent
           antialiasing: true

           onDegreeChanged: {
               requestPaint();
           }

           function nextStep(value){
               var s = parseInt(value)
               if(s > prevProg){
                   //console.log("before",tracker.primaryColor,tracker.secondaryColor)
                   prevProg = s
                   tracker.colorIndex = (tracker.colorIndex+1)%8
                   //console.log(tracker.colorIndex," is generated")
                   tracker.secondaryColor = tracker.primaryColor
                   tracker.primaryColor = tracker.colorList[tracker.colorIndex]
                   //console.log("after",tracker.primaryColor,tracker.secondaryColor)
               }
               value = value - s
               progressBar.degree = value * 360
           }

           onPaint: {
               var ctx = getContext("2d");

               var x = tracker.width/2;
               var y = tracker.height/2;

               var radius = tracker.diameter/2 - tracker.lineWidth
               var startAngle = (Math.PI/180) * 270;
               var fullAngle = (Math.PI/180) * (270 + 360);
               var progressAngle = (Math.PI/180) * (270 + degree);
               //console.log(x,y,radius,startAngle,fullAngle,progressAngle)

               ctx.reset()

               ctx.lineCap = 'round';
               ctx.lineWidth = tracker.lineWidth;

               ctx.beginPath();
               ctx.arc(x, y, radius, startAngle, fullAngle);
               ctx.strokeStyle = tracker.secondaryColor;
               ctx.stroke();

               ctx.beginPath();
               ctx.arc(x, y, radius, startAngle, progressAngle);
               ctx.strokeStyle = tracker.primaryColor;
               ctx.stroke();
           }

           Behavior on degree {
               NumberAnimation {
                   duration: tracker.animationDuration
               }
           }
       }

}

