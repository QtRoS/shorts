import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

import "../utils/databasemodule_v2.js" as DB

Column {
    id: topicComponentRoot

    property bool isExpanded: false
    property string topicName
    property int topicId
    property int modelIndex

    signal edit()
    signal editCanceled()

    onStateChanged: if (isExpanded) reloadFeed()

    function reloadFeed (){
        feedModel.clear()
        var feedsTags =  DB.loadFeedsFromTag(topicId)
        for (var i = 0; i < feedsTags.rows.length; i++) {
            feedModel.append(feedsTags.rows[i])
        }
    }

    function cancelEdit() {
        rowTopicContent.isEditing = false
        inputTopicName.text = topicName
    }

    function confirmEdit() {
        var topicNameLocal = inputTopicName.text.replace(/^\s+|\s+$/g, '')

        if (!topicNameLocal) {
            console.log("Empty topic name, edit aborted.")
            inputTopicName.text = labelTopicName.text
        } else {
            /* Make first letter capital.
         */
            topicNameLocal = topicNameLocal.charAt(0).toUpperCase() + topicNameLocal.slice(1)

            var result = DB.updateTag(topicComponentRoot.topicId, topicNameLocal)
            if (result.rowsAffected === 1) {
                //mainView.changeTopicName(topicComponentRoot.topicId, topicNameLocal)
                labelTopicName.text = topicNameLocal
                topicName = topicNameLocal
            }
            else {
                inputTopicName.text = labelTopicName.text
            }
        }

        cancelEdit()
    }

    anchors {
        left: parent.left
        right: parent.right
    }
    height: columnContent.height + feedList.height

    ListItem {
        id: topicComponent

        height: columnContent.height

        leadingActions: ListItemActions {
            actions: [
                Action {
                    iconName: "delete"
                    onTriggered: topicManagement.removeTopic(topicComponentRoot.topicId, topicComponentRoot.modelIndex)
                }
            ]
        }

        trailingActions: ListItemActions {
            actions: [
                Action {
                    iconName: "edit"
                    onTriggered: {
                        rowTopicContent.isEditing = true
                        topicComponentRoot.edit()
                        inputTopicName.focus = true
                    }
                }
            ]
        }

        Behavior on height {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        Column {
            id: columnContent
            anchors{ left: parent.left; right: parent.right }

            /*
          topic item
        */
            Item {
                anchors{ left: parent.left; right: parent.right }
                height: units.gu(5)

                /*
              enable if edit mode active
            */
                Row {
                    id: rowTopicContent
                    anchors {
                        top: parent.top; bottom: parent.bottom; left: parent.left;
                        leftMargin: units.gu(1); topMargin: units.gu(0.7); bottomMargin: units.gu(1);
                    }
                    spacing: units.gu(2)

                    property bool isEditing: false

                    Label {
                        id: labelTopicName
                        objectName: "labelTopicName"
                        anchors.verticalCenter: parent.verticalCenter
                        text: topicName
                        width: rowTopicContent.isEditing ? 0 : paintedWidth
                        opacity: rowTopicContent.isEditing ? 0 : 1

                    }

                    TextField {
                        id: inputTopicName
                        anchors.verticalCenter: parent.verticalCenter
                        text: topicName
                        width: rowTopicContent.isEditing ? topicComponent.width - units.gu(11) : 0
                        opacity: rowTopicContent.isEditing ? 1 : 0
                        hasClearButton: true
                        activeFocusOnPress: true

                        Behavior on width { UbuntuNumberAnimation{} }

                        onAccepted: {
                            console.log("accepted?")
                            Qt.inputMethod.hide()
                        }

                        Keys.enabled: rowTopicContent.isEditing
                        Keys.onPressed: {
                            event.accepted = false
                            if (event.key == Qt.Key_Return) {
                                Qt.inputMethod.hide()
                            }
                        }
                    }
                } // Row

                Icon {
                    id: imgArrow
                    anchors {
                        right: parent.right; top: parent.top; bottom: parent.bottom;
                        topMargin: units.gu(1.5); bottomMargin: units.gu(1.5); rightMargin: units.gu(2)
                    }
                    name: "go-to"
                    rotation: topicComponentRoot.isExpanded ? 90 : 0

                    Behavior on rotation { UbuntuNumberAnimation{} }
                } // Image


            }


        }

        onClicked: {
            isExpanded = !isExpanded
            editCanceled()
        }

        /* When item is expanded, "delete" icon is too big, so we should
     * collapse it first.
     */
        onContentMovementStarted: {
            //            isExpanded = false
            editCanceled()
        }
    }


    /*
  feeds listview
*/
    ListView {
        id: feedList
        anchors {
            left: parent.left
            right: parent.right
        }
        height: 0
        opacity: 0
        interactive: false
        clip: true

        property int transitionDuration: 250

        Behavior on opacity {
            PropertyAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        model: ListModel {
            id: feedModel
        }

        delegate: Item {
            id: delegateFeed

            width: feedList.width
            height: feedItem.height

            property int feedId: model.id
            property int topicId: topicComponentRoot.topicId
            property var topicItem

            FeedComponent {
                id: feedItem
                text: model.title
                width: topicList.width
                height: units.gu(6)

                onDeleteClicked: {
                    topicManagement.removeFeed(model.id)
                    reloadFeed()
                }

                onClicked: {
                    editFeedPageLoader.doAction( function(page) {
                        page.setValues(model.id, model.title, model.source, delegateFeed.topicId)
                        pageStack.push(page, topicManagement)
                    })
                }


            } // FeedComponent
        }

    } // ListView


    states: [
        State {
            name: "expanded"
            when: isExpanded
            PropertyChanges {
                target: feedList
                height: feedList.contentItem.childrenRect.height
                opacity: 1
            }
        },

        State {
            name: ""
            PropertyChanges {
                target: feedList
                height: 0
                opacity: 0
            }
        }
    ]
}
