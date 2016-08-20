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
                    if (previousTopicId != newTopicId) {
                        DB.deleteFeedTag(feedId, previousTopicId)
                        DB.addFeedTag(feedId, newTopicId)
                        apply(feedId, newTopicId, previousTopicId)
                    }
                    pageStack.pop(editPage)
                }
            }
        ]
    }

    signal apply(int feedId, int newTopicId, int previousTopicId)
    signal deleteFeed(int feedId, int topicId)

    property int feedId
    property string feedTitle: ""
    property string feedURL: ""
    property int previousTopicId
    property int newTopicId
    property var dbTags
    property var topicArray

    function setValues(feedid, title, url, pTopicId) {
        feedId = feedid ;
        feedTitle = title ;
        feedURL = url ;
        previousTopicId = pTopicId ;
        newTopicId = pTopicId
        topicArray = [] ;
        var tags = DB.loadTags() ;
        var tArray = [] ;
        var tagsArray = [] ;
        var index
        for (var i=0; i<tags.rows.length; i++) {
            if(tags.rows[i].id == previousTopicId)
                index = i
            tArray.push(tags.rows[i].name) ;
            tagsArray.push(tags.rows[i]) ;
        }
        dbTags = tagsArray ;
        topicArray = tArray ;
        seletorTopic.selectedIndex = index ;
    }

    function reloadPageContent() { }

    Flickable {
        id: content
        anchors { fill: parent; topMargin: units.gu(2) }
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

                TextField
                {
                    text: feedTitle
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
                    text: feedURL
                    width: parent.width - labelURL.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    readOnly: true
                    hasClearButton: false
                }
            }

            ListItem.ValueSelector {
                objectName: "valueselector"
                id: seletorTopic
                text: i18n.tr("Topic: ")
                values: (topicArray && topicArray.length) ? topicArray : [""]

                onSelectedIndexChanged: {
                    var tArray = topicArray
                    var topicname = tArray[seletorTopic.selectedIndex]
                    var tags = dbTags
                    console.log("detail: ", JSON.stringify(tags))
                    for (var i=0; i<tags.length; i++) {
                        if(tags[i].name == topicname) {
                            newTopicId = tags[i].id
                            break
                        }
                    }
                    console.log("new topic id: ", newTopicId)
                }
            }
        }
    }
}
