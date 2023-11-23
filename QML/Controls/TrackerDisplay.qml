import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item{
    id: tracker

    readonly property alias majorProgress: majorProgress
    readonly property alias miniProgress: miniProgress
    readonly property alias timeDisplayText: timeDisplayText

    TextTemplate {
        id: timeDisplayText
        text: qsTr(app.trackerInfo.tString)
        font.pointSize: 13 * app.scaleFactor
        font.family: "Helvetica"
        anchors.centerIn: parent
        width: diameter
        horizontalAlignment: Text.AlignHCenter
        color: app.primaryColor
        font.weight: Font.DemiBold
        style: Text.Outline
        styleColor: Color.transparent(app.primaryColor,0.2)
    }


    // Properties Related to Canvas / Progress Bar
    // This is taken from https://github.com/rafzby/circular-majorProgress
    // -------------------------------------------------------------------
    property real c_x: tracker.width/2;
    property real c_y: tracker.height/2;
    property int majorLineWidth: 10
    property int minorLineWidth: majorLineWidth/2

    property int animationDuration: 1000

    property int diameter: 50
    property color primaryColor: app.primaryColor
    property color secondaryColor: Material.color(Material.Grey,Material.Shade100)
    property color miniProgressStrokeColor: Color.transparent(tracker.primaryColor, 0.5)


    onDiameterChanged: {
        if(diameter > tracker.width) diameter = tracker.width

        majorProgress.radius = tracker.diameter/2
        miniProgress.radius = tracker.diameter/2 - majorLineWidth
    }

    function nextStep(seconds){
        var t = (seconds%60)/60;
        miniProgress.degree = (t - parseInt(t))*360;
        if(!miniProgress.degree) miniProgress.degree = 1

        t = (seconds%3600)/3600;
        majorProgress.degree = (t - parseInt(t))*360;
        if(majorProgress.degree < 1) majorProgress.degree = 1

        //timeDisplayText.text = qsTr(app.trackerInfo.tString)
    }

    Canvas {
        id: majorProgress
        anchors.fill: parent
        antialiasing: true

        property int degree: 0
        property real radius

        onDegreeChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");

            var startAngle = (Math.PI/180) * 270;
            var fullAngle = (Math.PI/180) * (270 + 360);
            var progressAngle = (Math.PI/180) * (270 + degree);

            ctx.reset()

            ctx.lineCap = 'round';
            ctx.lineWidth = majorLineWidth;

            ctx.beginPath();
            ctx.arc(c_x, c_y, radius, startAngle, fullAngle);
            ctx.strokeStyle = tracker.secondaryColor;
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(c_x, c_y, radius, startAngle, progressAngle);
            ctx.strokeStyle = tracker.primaryColor;
            ctx.stroke();
        }

        Behavior on degree {
            NumberAnimation {
                duration: tracker.animationDuration
            }
        }
    }

    Canvas{
       id: miniProgress
       anchors.fill: parent
       antialiasing: true

       property real degree: 0
       property real radius

       onDegreeChanged: requestPaint();

       onPaint: {
           var ctx = getContext("2d");

           var startAngle = (Math.PI/180) * 270;
           var fullAngle = (Math.PI/180) * (270 + 360);
           var progressAngle = (Math.PI/180) * (270 + degree);

           ctx.reset()

           ctx.lineCap = 'round';
           ctx.lineWidth = minorLineWidth;

           ctx.beginPath();
           ctx.arc(c_x, c_y, radius, startAngle, progressAngle);
           ctx.strokeStyle = miniProgressStrokeColor;
           ctx.stroke();
       }

       Behavior on degree {
           //enabled: miniProgress.degree < (59/60)*360
           NumberAnimation {
               duration: tracker.animationDuration
           }
       }
    }
}

