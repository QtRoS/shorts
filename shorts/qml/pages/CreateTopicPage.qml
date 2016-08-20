import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB

Page {
    id: createTopicPage

    visible: false
    flickable: null

    signal topicAdded()

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Create new topic")

        trailingActionBar.actions: [
            Action {
                text:  i18n.tr("Add topic")
                iconName: "ok"
                enabled: tfTopicName.length > 0

                onTriggered: {

                    var topicName = tfTopicName.text.replace(/^\s+|\s+$/g, '') // Trimming whitespaces.
                    if (!topicName) {
                        PopupUtils.open(errorDialogComponent, createTopicPage,
                                        {"text" : i18n.tr("Topic name can't contain only whitespaces"),
                                            "title" : i18n.tr("Warning")})
                        return
                    }

                    /* Make first letter capital.
                                     */
                    topicName = topicName.charAt(0).toUpperCase() + topicName.slice(1)

                    var dbResult = DB.addTag(topicName)
                    if (dbResult.error) {
                        PopupUtils.open(errorDialogComponent, createTopicPage,
                                        {"text" : i18n.tr("A topic with this name already exists"),
                                            "title" : i18n.tr("Warning")})
                        return
                    } else {
                        tfTopicName.text = ""

                        for( var i = 0; i < suggestionFeedsModel.count; i++) {
                            var curItem = suggestionFeedsModel.get(i)

                            if (curItem.feedSelected) {
                                DB.addFeedTag(curItem.feedId, dbResult.tagId)
                            }
                        }
                    }

                    topicAdded()
                    pageStack.pop(createTopicPage)
                }
            }
        ]
    }

    function reloadPageContent() {
        suggestionFeedsModel.clear()

        //var feeds = DB.loadFeeds()
        var feeds = DB.loadFeedsWithoutTopic()

        for( var i = 0; i < feeds.rows.length; i++) {
            var curFeed = feeds.rows.item(i)

            suggestionFeedsModel.append({"title" : curFeed.title,
                                            "feedId" : curFeed.id,
                                            "feedSelected" : false})
        }
    }

    Column {
        id: someColumn

        anchors.top: pageHeader.bottom
        anchors.topMargin: units.gu(2)
        width: parent.width
        spacing: units.gu(2)

        TextField {
            id: tfTopicName

            placeholderText: i18n.tr("Type topic name")

            width: parent.width - units.gu(4)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            onAccepted: {
                Qt.inputMethod.hide()
            }
        }

        ListItem.Header {

            ListItem.ThinDivider { }

            text: i18n.tr("Select feeds (optional)")
        }
    } // Column


    ListView {
        id: suggestionFeeds

        width: parent.width
        clip: true
        anchors {
            bottom: parent.bottom
            // bottomMargin: createTopicTools.height
            top: someColumn.bottom
        }

        model: suggestionFeedsModel

        delegate: ListItem.Standard {
            text: model.title
            control: CheckBox {
                anchors.verticalCenter: parent.verticalCenter

                onCheckedChanged: {
                    suggestionFeedsModel.setProperty(index, "feedSelected", checked)
                }
            }
        }
    }

    ListModel {
        id: suggestionFeedsModel
    }

    Label {
        visible: suggestionFeedsModel.count == 0
        anchors {
           centerIn: suggestionFeeds
        }
        text: i18n.tr("No feeds")
        fontSize: "large"
    }

} // Page
