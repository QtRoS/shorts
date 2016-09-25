import QtQuick 2.4
import Ubuntu.Components 1.3
import "../utils/databasemodule_v2.js" as DB

ListItem {
    id: feedComponent

    signal deleteClicked
    property alias text: lblTitle.text

    Label {
        id: lblTitle
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: units.gu(3)
        anchors.left: parent.left
    }

    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: deleteClicked()
            }
        ]
    }
}
