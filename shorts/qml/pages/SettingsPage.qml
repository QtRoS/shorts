import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    id: pageSettings

    visible: false
    flickable: null

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Settings")
    }

    property bool preventSave: false

    Component.onCompleted: updateInfoFromOptions()

    function updateInfoFromOptions() {
        preventSave = true

        swUseGfa.checked = optionsKeeper.useGoogleSearch

        preventSave = false
    }

    Column {
        anchors {
            top: pageHeader.bottom; topMargin: units.gu(1)
            left: parent.left; leftMargin: units.gu(1)
            right: parent.right; rightMargin: units.gu(1)
        }
        height: childrenRect.height
        spacing: units.gu(0.8)

        /////////////////////////////////////////////////////////////////////   Google RSS engine switch    start here
        Label {
            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: i18n.tr("For those who living in some special regions cannot access Google, the switch below can disable Google RSS engine, Shorts will directly get data from RSS sources.")
        }

        Item { width: 10; height: 1 } // just a separator

        Item {
            anchors { left: parent.left; right: parent.right; }
            height: childrenRect.height

            Label {
                text: i18n.tr("Use Google Search: ")
            }

            Switch {
                id: swUseGfa
                anchors.right: parent.right

                onCheckedChanged: {
                    if (preventSave)
                        return
                    optionsKeeper.useGoogleSearch = checked
                }
            }
        }

        ListItem.ThinDivider{ }

        /////////////////////////////////////////////////////////////////////   YaD login starts
        Label {
            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: i18n.tr("You can use Yandex.Disk cloud storage service to sync your feeds across devices.")
        }

        Item { width: 10; height: 1 } // just a separator

        Item {
            anchors { left: parent.left; right: parent.right; }
            height: btnYadLogin.height

            property bool loggedIn: !!optionsKeeper.yadToken

            Button {
                id: btnYadLogin

                text: parent.loggedIn ? "Log out Yandex.Disk" : "Login Yandex.Disk"
                color: "#EB6536"
                anchors.centerIn: parent
                onClicked: {
                    if (parent.loggedIn) {
                        optionsKeeper.yadToken = ""
                        yadLoginPage.logout()
                        pageStack.push(yadLoginPage, pageSettings, false, { } )
                    }
                    else {
                        pageStack.push(yadLoginPage, pageSettings, false, { } )
                        yadLoginPage.login()
                    }
                }
            }
        }

        ListItem.ThinDivider{ }

    }// Column

}
