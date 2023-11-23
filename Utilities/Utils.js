.pragma library

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

function generateUuid(){
    return 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.replace(/[x]/g, (c) => {
        const r = Math.floor(Math.random() * 16);
        return r.toString(16);
  });
}
