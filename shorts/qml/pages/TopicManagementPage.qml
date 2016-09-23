import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.Layouts 1.0

import "../utils/databasemodule_v2.js" as DB

Page {
    id: topicManagement
    objectName: "topicmanagement"

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Edit topics")
        //flickable: content

        leadingActionBar.actions: [
            Action {
                text: i18n.tr("Cancel")
                iconName: "cancel"
                visible: topicManagement.state == "editMode"

                onTriggered: {
                    Qt.inputMethod.hide()
                    topicList.currentItem.cancelEdit()
                    topicManagement.state = "default"
                    topicList.currentIndex = -1
                }
            },

            Action {
                text: i18n.tr("Back")
                iconName: "back"
                visible: topicManagement.state != "editMode"

                onTriggered: {
                    pageStack.pop(mainPage)
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                text: i18n.tr("Confirm")
                iconName: "ok"
                visible: topicManagement.state == "editMode"

                onTriggered: {
                    topicList.currentItem.confirmEdit()
                    topicManagement.state = "default"
                    topicList.currentIndex = -1
                }
            },

            Action {
                text: i18n.tr("Add topic")
                iconName: "add"
                visible: topicManagement.state != "editMode"

                onTriggered: createTopicPageLoader.doAction(function(page) { pageStack.push(page, topicManagement) } )
            }
        ]
    }

    signal topicDeleted(string type)

    Component.onCompleted: {
        reloadTopics ()
    }

    function reloadTopics () {
        topicModel.clear()
        var topics = DB.loadTags()
        for (var i = 0; i < topics.rows.length; i++){
            topicModel.append({"id": topics.rows[i].id
                                  ,"name": topics.rows[i].name } )
        }
    }

    function removeTopic(topicId, modelIndex){
        topicModel.remove(modelIndex)
        DB.deleteFeedByTagId(topicId)
        DB.deleteTag(topicId)
        topicDeleted("topicDeleted")
    }

    function removeFeed(feedId) {
        var result = DB.deleteFeed(feedId)
        topicDeleted("topicDeleted") // Actually feed is deleted, but it is ok.
    }

    function reloadPageContent() {
        topicManagement.flickable = null
        topicManagement.flickable = content
    }

    /*
      main content
    */
    Flickable {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: pageHeader.bottom
            bottom: parent.bottom
        }
        contentHeight: contentItem.childrenRect.height
        clip: true // TODO

        Column {
            anchors{ left: parent.left; right: parent.right }

            /*
              add topic button
            */
            Item {
                id: itemAddTopic
                objectName: "addTopic"
                anchors{ left: parent.left; right: parent.right }
                height: units.gu(9)

                Button {
                    id: btnAddTopic

                    objectName: "btnAddTopic"
                    text: i18n.tr("Add feed")
                    color: "#EB6536"
                    anchors { fill: parent; margins: units.gu(2) }
                    onClicked: appendFeedPageLoader.doAction(function(page) { pageStack.push(page, topicManagement) }) // pageStack.push(appendFeedPage, topicManagement)
                }
            }

            /*
              topic listview
            */
            ListView {
                id: topicList
                anchors{ left: parent.left; right: parent.right }
                height: contentItem.childrenRect.height
                interactive: false
                currentIndex: -1

                property int feedSelectedIndex: -1

                signal collapseAllItem()

                function collapseAll(){
                    collapseAllItem()
                }

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
                }

                model: ListModel {
                    id: topicModel
                }

                delegate: MouseArea {
                    id: delegateRoot

                    property alias isExpanded: topicItem.isExpanded

                    anchors { left: parent.left; right: parent.right }
                    height: topicItem.height

                    function cancelEdit() {
                        topicItem.cancelEdit()
                    }

                    function confirmEdit() {
                        topicItem.confirmEdit()
                    }

                    TopicComponent {
                        id: topicItem
                        topicName: model.name
                        topicId: model.id
                        modelIndex: model.index

                        onEdit: {
                            if (topicList.currentItem)
                                topicList.currentItem.cancelEdit()
                            topicManagement.state = "editMode"
                            topicList.currentIndex = index
                        }

                        onEditCanceled: {
                            if (topicList.currentItem)
                                topicList.currentItem.cancelEdit()
                            topicManagement.state = "default"
                            topicList.currentIndex = -1
                        }
                    }

                    Connections {
                        id: connTopicList
                        target: topicList

                        onCollapseAllItem: {
                            delegateRoot.isExpanded = false
                        }
                    }

//                    Connections {
//                        id: connEditFeed0
//                        target: editFeed
                        // TODO BUG
//                        onApply:{
//                            if (model.id == newTopicId || model.id == previousTopicId){
//                                topicItem.reloadFeed()
//                                topicItem.isExpanded = true
//                            }
//                        }
//                    }

                }
            }

        }
    }

    states: [
        State {
            name: "default"
        },
        State {
            name: "editMode"
        }
    ]

}
