import QtQuick 2.0
import Ubuntu.Components 1.1

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "manyapps.sil"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    Page {
        title: i18n.tr("subapp")

        Column {
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                fill: parent
            }

            Label {
                property bool isset: false
                property int number: 0
                id: lbl
                text: "Not launched yet"
                width: parent.width
                wrapMode: Text.WrapAnywhere
            }

            Connections {
                target: UriHandler
                onOpened: {
                    if (lbl.isset) {
                        var parsed = uris[0].match(/^(subapp)([0-9]+)(:\/\/.*)$/);
                        var outurl = "subapp" + (lbl.number+1) + parsed[3];
                        lbl.text += " | now opening " + outurl;
                        Qt.openUrlExternally(outurl);
                    } else {
                        // got a URL at runtime but didn't already have one.
                        // This isn't supposed to happen.
                        lbl.isset = true;
                        console.log("uri opened: " + uris[0]);
                        lbl.text = "opened runtime" + uris[0];
                    }
                }
            }

            Component.onCompleted: {
                var args = Array.prototype.slice.call(
                            Qt.application.arguments
                        );
                var urls = args.filter(function(s) {
                    return s.match(/^subapp[0-9]+:\/\//);
                });
                lbl.number = parseInt(args[args.length-1], 10);
                if (urls.length > 0) {
                    console.log("startup url opened: " + urls[0]);
                    lbl.text = "startup url opened: " + urls[0] + " (Params were " + JSON.stringify(args) + ", I am " + lbl.number + ")";
                    lbl.isset = true;
                } else {
                    console.log("no startup url");
                    lbl.text = "no startup url";
                }
            }
        }
    }
}

