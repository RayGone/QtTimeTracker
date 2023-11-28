.pragma library

/* -----------------------------------
  ------- Readable Time Strings ------------
  ------------------------------------*/
function computeTrackedReadableTimeString(seconds){
    var m = parseInt(seconds/60)
    var s = seconds - m*60
    var h = parseInt(m/60)
    m = m - h*60
    return (h<10? "0"+h : h) + " : " + (m<10? "0"+m : m) + " : " + (s<10 ? "0"+s : s)
}

function readableTimeString(seconds){
    if(seconds < 60) return seconds+" seconds"
    var minutes = seconds / 3600
    var hours = parseInt(minutes)
    minutes = Math.ceil((minutes - hours) * 60)

    return (hours? hours + "H" + " " : "") + (minutes ? minutes + "M" : "")
}


function getDateString(dObj,format="YY-MM-DD"){
    dObj = new Date(dObj);
    var date = dObj.getDate()
    date = date < 10 ? "0" + date : date
    var month = dObj.getMonth()+1
    month = month < 10 ? "0" + month : month
    var year = dObj.getFullYear()

    return format.replace("YY",year).replace("MM",month).replace("DD",date)
}

/* -----------------------------------
  ------- Utilities ------------
  ------------------------------------*/

function generateUuid(){
    return 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.replace(/[x]/g, (c) => {
        const r = Math.floor(Math.random() * 16);
        return r.toString(16);
  });
}

/* -----------------------------------
  ------- Date Functions ------------
  ------------------------------------*/
function dateInvterval(from, days=1){
    from = new Date(from);
    var time = days * 86400 * 1000;
    time = from.getTime() + time

    return new Date(time);
}

function dateDifference(Date1,Date2){
    var dateFirst = new Date(Date1)
    dateFirst = new Date(dateFirst.getFullYear(),dateFirst.getMonth(),dateFirst.getDate())
    var dateSecond = new Date(Date2)
    dateSecond = new Date(dateSecond.getFullYear(),dateSecond.getMonth(),dateSecond.getDate())

    // time difference
    var timeDiff = Math.abs(dateSecond.getTime() - dateFirst.getTime());
    // days difference
    var diffDays = Math.floor(timeDiff / (1000 * 3600 * 24));
    return diffDays;
}

function dateTimeDifferenceMS(Date1,Date2){
    var dateFirst = new Date(Date1)
    var dateSecond = new Date(Date2)

    // time difference
    var timeDiff = Math.abs(dateSecond.getTime() - dateFirst.getTime());
    return timeDiff;
}

function dateTimeCompare(Date1,Date2){
    // time difference
    var timeDiff = parseInt(dateTimeDifferenceMS(Date1,Date2)/60);

    if(timeDiff > 0){
        return 1
    } else if(timeDiff < 0){
        return -1
    } else {
        return 0
    }
}
