import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import "../"

Rectangle{
    id: report
    width: 20
    height: 20
    radius: width/2
    visible: main.active
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: Material.color(Material.Blue,Material.Shade700)
    border.color: Material.color(Material.Blue,Material.Shade900)
    border.width: 3
    clip: true

    property string dumpLocation: main.settings.value("report-dump-locaton","file:///D:")
    property string imgSrc: ""

    signal dumpReport()
    signal fileSaved()

    Image{
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        source: imgSrc
    }

    MouseArea{
        anchors.fill: parent

        onClicked: {
            dumpReport()
        }

        onDoubleClicked: {
            //dump time tracked file
            dumpData()
        }
    }


    function dumpData(){
        var csv_string = "";
        main.database.transaction(
            function(tx){
                // var rs = tx.executeSql("SELECT trackid as SN,work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Started_At, date(datetime(datetime(end,'unixepoch'),'localtime')) as Ended_At, tracked_time as Tracked_Seconds FROM TimeTracks")
                var query = "
                    SELECT work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Work_Date, sum(CAST(tracked_time AS REAL))/60 as Worked_Minutes
                    FROM TimeTracks
                    GROUP BY Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime'))
                    ORDER BY start
                ";
                var rs = tx.executeSql(query)

                for(var i=0;i<rs.rows.length;i++){
                    if(i==0){
                        var keys = Object.keys(rs.rows.item(i)).join(',')
                        csv_string += keys + "\n";
                    }
                    csv_string += Object.values(rs.rows.item(i)).join(",") + "\n"
                }
                console.log(csv_string)

                var filename = report.dumpLocation+"/Time_Track_Log.csv"
                try{
                    saveFile(filename,csv_string)
                }
                catch(e){
                    console.log(e)
                }
                fileSaved()
            })
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, true);
        request.send(text);
        return request.status;
    }

}
