import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB

Page {
    id: chooseTopicPage

    objectName: "choosetopicpage"
    title: i18n.tr("Choose topic")
    flickable: null

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Choose topic")
        flickable: suggestionTopics
    }

    property var feedsToAdd: null
    property Page parentPage: null
    signal topicChoosen(int topicId, var addedFeeds)

    function reloadPageContent() {
        suggestionTopicsModel.clear()

        var tags = DB.loadTags()

        for (var i = 0; i < tags.rows.length; i++) {
            var curTag = tags.rows.item(i)

            suggestionTopicsModel.append({"tagName" : curTag.name, "tagId" : curTag.id})
        }
    }

    function appendFeedsToTopic(topicId) {
        var tagId = topicId

        var updateList = []

        for(var i = 0; i < feedsToAdd.length; i++) {

            var f = feedsToAdd[i]

            var feedTitle = f.title
            feedTitle = feedTitle.replace(/<[^>]*>/g, '')

            var dbResult = DB.addFeed(feedTitle, f.url)

            if (dbResult.error) {
                continue
            }

            DB.updateFeedByXml(dbResult.feedId, f.link, f.description, feedTitle)
            DB.addFeedTag(dbResult.feedId, tagId)

            updateList.push({"source" : f.url, "link" : f.link, "id" : dbResult.feedId})
        }

        pageStack.pop(parentPage)
        topicChoosen(tagId, updateList)
    }

    ListView {
        id: suggestionTopics

        width: parent.width
        clip: true
        anchors {
            left: parent.left; right: parent.right
            top: parent.top; bottom: parent.bottom
        }

        model: suggestionTopicsModel

        header: ListItem.Header {
            ListItem.ThinDivider { }
            text: i18n.tr("Add your new feeds to a topic")
        }

        footer: Item {
                    width: parent.width
                    height: tfNewTopicName.height + units.gu(2)

                    TextField {
                        objectName: "newTopic"
                        id: tfNewTopicName

                        placeholderText: i18n.tr(" + New topic")

                        width: parent.width - units.gu(4)
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        onAccepted: {
                            var tagName = text.replace(/^\s+|\s+$/g, '')  // Trimming whitespaces.
                            if (tagName != "") { // Check that tagName contains only spaces.

                                /* Make first letter capital.
                                 */
                                tagName = tagName.charAt(0).toUpperCase() + tagName.slice(1)

                                var dbResult = DB.addTag(tagName)

                                if (dbResult.error) {
                                    PopupUtils.open(errorDialogComponent, chooseTopicPage,
                                                    {"text" : i18n.tr("A topic with this name already exists"),
                                                        "title" : i18n.tr("Warning")})
                                    return
                                }

                                suggestionTopicsModel.append({"tagName" : tagName,
                                                                 "tagId" : dbResult.tagId})

                                text = ""

                                appendFeedsToTopic(dbResult.tagId)
                            } else {
                                PopupUtils.open(errorDialogComponent, chooseTopicPage,
                                                {"text" : i18n.tr("Topic name can't contain only whitespaces"),
                                                    "title" : i18n.tr("Warning")})
                            }
                        }
                    }
                }

        delegate: ListItem.Standard {
            objectName: "topicItem"
            text: model.tagName

            onClicked: {
                console.log("Topic selected", model.tagId, model.tagName)

                appendFeedsToTopic(model.tagId)
            }
        }
    }

    ListModel {
        id: suggestionTopicsModel
    }
}
