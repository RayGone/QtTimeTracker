import QtQuick 2.15
import QtQuick.Dialogs

MessageDialog{
    id: dialog
    buttons: MessageDialog.Ok | MessageDialog.Cancel

    //title: qsTr("<u>Update App</u>")
    title: qsTr("<b>Update of TimeTracker App is available for download!!!!</b>")
    property url link

    function checkForUpdates(){
        // Creating a new XMLHttpRequest object
        var request = new XMLHttpRequest();

        // Setting the request method and the URL to send the request to
        request.open('GET', settings.app_release_url);

        // Setting a callback function to handle the response
        request.onload = function() {

          // Checking the status code of the response
            if (request.status === 200) {

                // Parsing the response as JSON and logging it to the console
                var data = JSON.parse(request.responseText);
                //console.log(JSON.stringify(data[0]));

                var version = data[0]['tag_name'];
                dialog.text = qsTr("New version: <b>" +
                                              version +
                                              "</b> is available for download. The current version of the app is <b>" +
                                              settings.app_version + "</b>.<br>Click <b>OK</b> to download.");
                dialog.link = data[0]['assets'][0]['browser_download_url'];
                //console.log(JSON.stringify({version,download_url}));

                if(isNewVersion(version)){
                    dialog.open();
                }

            }
            else {
                // Logging an error message to the console
                console.error('[AppUpdate]: Request failed: ' + request.status);
          }
        };
        // Sending the request
        request.send();
    }

    function isNewVersion(version){
        version = version.split('.')
        var app_version = app.settings.app_version.split(".")

        //console.log(version, app_version)

        if(version[0] !== app_version[0]){
            version[0] = parseInt(version[0].replace('v','0'))
            app_version[0] = parseInt(app_version[0].replace('v','0'))

            if(version[0] > app_version[0]) return true
        }

        else if(parseInt(version[1]) > parseInt(app_version[1])) return true

        else if(parseInt(version[2]) > parseInt(app_version[2])) return true

        else return false;
    }

    onAccepted: {
        Qt.openUrlExternally(link);
    }
}
