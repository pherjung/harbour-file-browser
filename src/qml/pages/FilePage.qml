import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.file.browser.FileInfo 1.0
import "functions.js" as Functions

Page {
    id: page
    allowedOrientations: Orientation.All
    property string file: "/"

    FileInfo {
        id: fileInfo
        file: page.file
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        PullDownMenu {
            MenuItem {
                text: "Go to Root"
                onClicked: Functions.goToRoot()
            }
            MenuItem {
                text: "Install"
                visible: fileInfo.suffix === "apk" || fileInfo.suffix === "rpm"
                onClicked: {
                    if (fileInfo.suffix === "apk") {
                        pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                                       { title: "Install",
                                           successText: "Install Launched",
                                           infoText: "If the application is already installed, this will probably do nothing.",
                                           command: "apkd-install",
                                           arguments: [ fileInfo.file ] })
                    }
                    if (fileInfo.suffix === "rpm") {
                        pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                                       { title: "Install",
                                           successText: "Installed Successfully",
                                           command: "pkcon",
                                           arguments: [ "-y", "-p", "install-local", fileInfo.file ] })
                    }
                }
            }
            MenuItem {
                text: "View Contents"
                // file formats based on zip
                visible: fileInfo.suffix === "apk" || fileInfo.suffix === "zip" ||
                         fileInfo.suffix === "jar" || fileInfo.suffix === "docx" ||
                         fileInfo.suffix === "xlsx" || fileInfo.suffix === "pptx" ||
                         fileInfo.suffix === "odt" || fileInfo.suffix === "ods" ||
                         fileInfo.suffix === "odp"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                                   { title: "View Contents",
                                       initialText: "Reading Package",
                                       successText: "Files",
                                       command: "unzip",
                                       arguments: [ "-l", fileInfo.file ],
                                       consoleColor: "white"
                                   })
                }
            }
            MenuItem {
                text: "View Contents"
                visible: fileInfo.suffix === "rpm"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                                   { title: "View Contents",
                                       initialText: "Reading Package",
                                       successText: "Files",
                                       command: "rpm",
                                       arguments: [ "-qlp", fileInfo.file ],
                                       consoleColor: "white"
                                   })
                }
            }
        }

        Column {
            id: column
            width: parent.width
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge

            PageHeader { title: Functions.formatPathForTitle(fileInfo.absolutePath) }

            // file info texts, visible if error is not set
            Column {
                visible: fileInfo.errorMessage === ""
                anchors.left: parent.left
                anchors.right: parent.right

                Image {
                    id: icon
                    anchors.topMargin: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../images/large-"+fileInfo.icon+".png"
                }
                Label {
                    width: parent.width
                    text: fileInfo.name
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    visible: fileInfo.symLinkTarget !== ""
                    width: parent.width
                    text: "\u2192 "+fileInfo.symLinkTarget // uses unicode arrow
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Item { // used for spacing
                    width: parent.width
                    height: 40
                }
                Row {
                    width: parent.width
                    spacing: 10
                    Label {
                        id: firstLabel
                        text: "Location"
                        color: Theme.secondaryColor
                        width: parent.width/2
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        text: fileInfo.absolutePath
                        wrapMode: Text.Wrap
                        width: parent.width/2
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Row {
                    width: parent.width
                    spacing: 10
                    Label {
                        text: "Size"
                        color: Theme.secondaryColor
                        width: parent.width/2
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        text: fileInfo.size
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Row {
                    spacing: 10
                    Label {
                        text: "Permissions"
                        color: Theme.secondaryColor
                        width: firstLabel.width
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        text: fileInfo.permissions
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Row {
                    spacing: 10
                    Label {
                        text: "Last modified"
                        color: Theme.secondaryColor
                        width: firstLabel.width
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        text: fileInfo.modified
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                Row {
                    spacing: 10
                    Label {
                        text: "Created"
                        color: Theme.secondaryColor
                        width: firstLabel.width
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    Label {
                        text: fileInfo.created
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            // error label, visible if error message is set
            Label {
                visible: fileInfo.errorMessage !== ""
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                text: fileInfo.errorMessage
                wrapMode: Text.Wrap
            }
        }
    }

    // update cover
    onStatusChanged: {
        if (status === PageStatus.Activating) {
            coverPlaceholder.text = "File Browser\n"+Functions.formatPathForCover(page.file);
        }
    }
}


