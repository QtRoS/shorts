import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.Layouts 1.0

import "../utils/databasemodule_v2.js" as DB

Page {
    id: editPage
    objectName: "editfeedpage"

    header: PageHeader{
        id: pageHeader

        title: i18n.tr("Edit Feed")
        trailingActionBar.actions: [
            Action {
                objectName: "doneButton"
                iconName: "ok"
                text: i18n.tr("Done")
                onTriggered: {
                    var newTopicId = __topics[seletorTopic.selectedIndex].id
                    if (__prevTopicId !== newTopicId) {
                        DB.deleteFeedTag(__feedId, __prevTopicId)
                        DB.addFeedTag(__feedId, newTopicId)
                        feedEdited("feedEdited")
                    }
                    pageStack.pop(editPage)
                }
            }
        ]
    }

    signal feedEdited(string type)

    property int __prevTopicId
    property int __feedId
    property var __topics

    function setValues(feedid, title, url, pTopicId) {
        __prevTopicId = pTopicId
        __feedId = feedid

        var tags = DB.loadTags()
        var topicArray = []
        __topics = []

        for (var i = 0; i < tags.rows.length; i++) {
            if(tags.rows[i].id == __prevTopicId)
                seletorTopic.selectedIndex = i
            topicArray.push(tags.rows[i].name)
            __topics.push(tags.rows[i])
        }

        seletorTopic.model = topicArray
        tfTitle.text = title
        tfUrl.text = url
        console.log("EDIT FEED", feedid, title, url, __prevTopicId, topicArray)
    }

    function reloadPageContent() { }

    Flickable {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: pageHeader.bottom
            bottom: parent.bottom
        }
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > editPage.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            anchors{ left: parent.left; right: parent.right }
            spacing: units.gu(2)

            Row {
                anchors{ left: parent.left; right: parent.right; leftMargin: units.gu(2); rightMargin: units.gu(2) }
                spacing: units.gu(1)

                Label {
                    id: labelTitle
                    text: i18n.tr("Title: ")
                    width: units.gu(6)
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: tfTitle
                    width: parent.width - labelTitle.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    readOnly: true
                    hasClearButton: false
                }
            }

            Row {
                anchors{ left: parent.left; right: parent.right; leftMargin: units.gu(2); rightMargin: units.gu(2) }
                spacing: units.gu(1)

                Label {
                    id: labelURL
                    text: i18n.tr("URL: ")
                    width: labelTitle.width
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: tfUrl
                    width: parent.width - labelURL.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    readOnly: true
                    hasClearButton: false
                }
            }

            ListItem.ItemSelector {
                id: seletorTopic
                objectName: "valueselector"
                text: i18n.tr("Topic: ")
                expanded: false
            }
        }
    }
}
