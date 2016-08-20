import QtQuick 2.4
import Ubuntu.Components 1.3
import "../utils/databasemodule_v2.js" as DB

ListItem {
    id: feedComponent

    property string text
    property int feedId
    property int topicId

    Label {
        text: feedComponent.text
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: units.gu(3)
        anchors.left: parent.left
    }

    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    var result = DB.deleteFeed(feedId)
                    if (result.rowsAffected == 1)
                        feedDeleted()
                    topicComponentRoot.reloadFeed()
                }
            }
        ]
    }
}
