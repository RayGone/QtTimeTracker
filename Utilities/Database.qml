import QtQuick 2.15

Item {
    id: dbQueries

    function createDatabase(){
        app.database.transaction(
            function(tx) {
                // - Deprecated Query
                //tx.executeSql('DROP TABLE TimeTracks')
                //tx.executeSql('CREATE TABLE IF NOT EXISTS TimeTracks(trackid INTEGER PRIMARY KEY AUTOINCREMENT, work TEXT, start TIMESTAMP, end TIMESTAMP, tracked_time INTEGER)');

                // - New Query
                // Create the database if it doesn't already exist
                //tx.executeSql('DROP TABLE IF EXISTS TimeLogs');
                var query = "CREATE TABLE IF NOT EXISTS TimeLogs(id INTEGER PRIMARY KEY AUTOINCREMENT, job_id VARCHAR(50), job_title VARCHAR(50), job_desc VARCHAR(250), work_date TIMESTAMP default CURRENT_TIMESTAMP, logged_time INTEGER DEFAULT 0 )";
                //console.log(query)
                tx.executeSql(query);
            }
        )
        console.log('Database Initialized!!')
    }

    // deprecated function
    function insertStart(jobInfo){
        if(!work_desc) work_desc = "Work Item"
        app.database.transaction(
                    function(tx){
                        tx.executeSql("INSERT INTO TimeTracks(work,start,end,tracked_time) VALUES (?,strftime('%s'),strftime('%s'),0)",[work_desc])

                        tx.executeSql("SELECT last_insert_rowid() as id")
                    })
    }

    // deprecated function
    function insertEnd(tracked_time = 1,work_desc){
        app.database.transaction(
                    function(tx){
                        var rs = tx.executeSql("SELECT trackid FROM TimeTracks ORDER BY trackid DESC LIMIT 1")
                        var id = rs.rows.item(0)['trackid']

                        tx.executeSql("UPDATE TimeTracks SET tracked_time = ?, work = ?, end = strftime('%s') WHERE trackid=?",[tracked_time,work_desc,id])
                    })
    }

    function startLog(jobInfo){
        app.database.transaction(
                    function(tx){
                        var query = "INSERT INTO TimeLogs(job_id,job_title,job_desc) VALUES(?,?,?)"
                        tx.executeSql(query,[jobInfo.jobID,jobInfo.jobTitle,jobInfo.jobDesc])
                    }
                )
    }

    function updateLog(jobInfo){
        app.database.transaction(
                    function(tx){
                        var query = "UPDATE TimeLogs SET job_title = ?, job_desc = ?, logged_time = ? WHERE job_id = ?";
                        tx.executeSql(query,[jobInfo.jobTitle,jobInfo.jobDesc,jobInfo.trackedTime,jobInfo.jobID]);
                    }
                );

    }

    function getRecentWorkHistory(limit=10){
        var data = [];
        app.database.transaction(
            function(tx){
                var query = "
                    SELECT * FROM TimeLogs
                    ORDER BY id DESC
                    LIMIT ?
                ";
                var rs = tx.executeSql(query,[limit])
                for(var i=0;i<rs.rows.length;i++){
                    data.push(rs.rows.item(i));
                }
            }
        )
        return data
    }

    function getJobHistory(jobTitle){
        var data = [];
        app.database.transaction(
            function(tx){
                var query = "
                    SELECT * FROM TimeLogs
                    WHERE job_title = ?
                    ORDER BY work_date desc
                ";

                var rs = tx.executeSql(query,[jobTitle])
                for(var i=0;i<rs.rows.length;i++){
                    data.push(rs.rows.item(i));
                }
            }
        );
        return data;
    }

    function getLatestOfJob(jobTitle){
        var data = [];
        app.database.transaction(
            function(tx){
                var query = "
                    SELECT * FROM TimeLogs
                    WHERE job_title == ?
                    ORDER BY work_date desc
                    LIMIT 1
                ";
                var rs = tx.executeSql(query,[jobTitle])
                if(rs.rows.length){
                    data.push(rs.rows.item(0));
                }
            }
        );
        return data;
    }

    function filterByDate(limit=14){
        app.database.transaction(
            function(tx){
                // var rs = tx.executeSql("SELECT trackid as SN,work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Started_At, date(datetime(datetime(end,'unixepoch'),'localtime')) as Ended_At, tracked_time as Tracked_Seconds FROM TimeTracks")
                var query = "
                    SELECT work, date(datetime(datetime(start,'unixepoch'),'localtime')) as date, sum(CAST(tracked_time AS REAL))/60 as minutes
                    FROM TimeTracks
                    WHERE datetime(datetime(start,'unixepoch'),'localtime') > datetime('now','start of day',?,'localtime')
                    GROUP BY work, date(datetime(datetime(start,'unixepoch'),'localtime'))
                    ORDER BY start
                ";
                limit = "-"+(limit)+" day"
                var rs = tx.executeSql(query,[limit])

                tableModel.clear()
                tableModel.appendRow({work:"<b>Work Description</b>",date:"<b>Date</b>",hours:'<b>Hours</b>',minutes:"<b>Minutes</b>"})

                var total = 0
                for(var i=0;i<rs.rows.length;i++){
                    var item = rs.rows.item(i)
                    console.log('filterByDate',JSON.stringify(item))
                    total += parseInt(Math.ceil(item['minutes']))
                    item['hours'] = parseInt(parseInt(Math.ceil(item['minutes']))/60)
                    item['minutes'] = parseInt(Math.ceil(item['minutes']) - item['hours']*60)
                    tableModel.appendRow(item)
                }

                var summary_string = ""
                if(rs.rows.length > 0){
                    var from = rs.rows.item(0)['date']
                    var to = rs.rows.item(rs.rows.length-1)['date']

                    summary_string =      "Showing Log From&nbsp;&nbsp;&nbsp;: <b><i><u>"+from+"</u></i></b> to : <b><i><u>"+ to+"</u></i></b>"
                    summary_string += "<br>Total Worked Hours&nbsp;: <b><i><u>"+parseInt(total/60)+"hr"+" "+(total%60)+"min</u></i></b>"

                    console.log(parseInt(total/60)+"hr"+" "+(total%60)+"min")
                }else{
                    summary_string = "No logs to show.
                            Start tracking."

                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                }

                logsummary.text = summary_string
            });

    }

    function filterByWork_Date(limit=14){
        app.database.transaction(
            function(tx){
                // var rs = tx.executeSql("SELECT trackid as SN,work as Work_Description, date(datetime(datetime(start,'unixepoch'),'localtime')) as Started_At, date(datetime(datetime(end,'unixepoch'),'localtime')) as Ended_At, tracked_time as Tracked_Seconds FROM TimeTracks")
                var query = "
                    SELECT work, date(datetime(datetime(start,'unixepoch'),'localtime')) as date, sum(CAST(tracked_time AS REAL))/60 as minutes
                    FROM TimeTracks
                    WHERE datetime(datetime(start,'unixepoch'),'localtime') > datetime('now','start of day',?,'localtime')
                    GROUP BY work
                    ORDER BY start
                ";
                limit = "-"+(limit)+" day"
                var rs = tx.executeSql(query,[limit])

                tableModel.clear()
                tableModel.appendRow({work:"<b>Work Description</b>",date:"<b>From Date</b>",hours:'<b>Hours</b>',minutes:"<b>Minutes</b>"})
                console.log(query)
                var total = 0
                for(var i=0;i<rs.rows.length;i++){
                    var item = rs.rows.item(i)
                    console.log('filterByWork_Date',JSON.stringify(item))
                    total += parseInt(Math.ceil(item['minutes']))
                    item['hours'] = parseInt(parseInt(Math.ceil(item['minutes']))/60)
                    item['minutes'] = parseInt(Math.ceil(item['minutes']) - item['hours']*60)
                    tableModel.appendRow(item)
                }

                var summary_string = ""
                if(rs.rows.length > 0){
                    var from = rs.rows.item(0)['date']
                    var to = rs.rows.item(rs.rows.length-1)['date']

                    summary_string =      "Showing Log From&nbsp;&nbsp;&nbsp;: <b><i><u>"+from+"</u></i></b> to : <b><i><u>"+ to+"</u></i></b>"
                    summary_string += "<br>Total Worked Hours&nbsp;: <b><i><u>"+parseInt(total/60)+"hr"+" "+(total%60)+"min</u></i></b>"

                    console.log(parseInt(total/60)+"hr"+" "+(total%60)+"min")
                }else{
                    summary_string = "No logs to show.
                            Start tracking."

                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                    tableModel.appendRow({work:"-",date:"-",hours:'-',minutes:"-"})
                }

                logsummary.text = summary_string
            });
    }
}
