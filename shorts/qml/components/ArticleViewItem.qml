/*
  license GPL v3 ...........

  description of this file:
  a page for viewing a user selected RSS feed ;

*/

import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/dateutils.js" as DateUtils
import "../utils/databasemodule_v2.js" as DB

Item {
    id: articleViewRoot

    signal articleStatusChanged(var article, string status)
    signal articleFavouriteChanged(var article, string favourite)

    property bool showEmptyPlaceholder: true
    property bool isEmbeddedMode: false // Deprecated for now.

    property string feedTitle: ""
    property var articleModel: null
    property var modelItem: null

    property bool __preventIndexChangeHandler: false

    function setFeed(model, index) {
        /* Setting new model and not-null index will cause two change events instead of one.
         * Settings "preventIndexChangeHandler" to true helps to avoid it.
         */
        if (articleModel != model && index !== 0)
            __preventIndexChangeHandler = true
        articleModel = model
        setNewIndex(index)
    }

    function setNewIndex(rssIndex) {
        rssListview.currentIndex = rssIndex
        rssListview.positionViewAtIndex(rssListview.currentIndex, ListView.Center)
    }

    function showNextArticle() {
        var index = rssListview.currentIndex + 1
        if (rssListview.model && index < rssListview.model.count) {
            rssListview.currentIndex = index
        }
    }

    function showPrevArticle() {
        var index = rssListview.currentIndex - 1
        if (rssListview.model && index >= 0) {
            rssListview.currentIndex = index
        }
    }


    //////////////////////////////////////////////      a listview to show the RSS content
    ListView {
        id: rssListview

        property int contentFontSize: optionsKeeper.fontSize

        width: parent.width
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }

        model: articleModel
        delegate: articleDelegate
        snapMode: ListView.SnapOneItem
        cacheBuffer: 90 // value in pixels, for what?
        orientation: ListView.Horizontal
        contentHeight: parent.width * count
        highlightFollowsCurrentItem: true
        highlightMoveVelocity: 1000
        highlightRangeMode: ListView.StrictlyEnforceRange
        clip: true

        onCurrentIndexChanged: {
            console.log("ListView onCurrentIndexChanged", currentIndex, __preventIndexChangeHandler)

            if (__preventIndexChangeHandler) {
                __preventIndexChangeHandler = false
                return
            }

            if (articleModel == null || articleModel.get == undefined) {
                console.log("---- Stange behavior ----")
                console.trace()
                return
            }

            if (articleModel.count == 0) // It is normal bevaviour.
                return

            modelItem = articleModel.get(currentIndex)
            feedTitle = modelItem.feed_name

            if (modelItem.status != "1") {
                var dbResult = DB.updateArticleStatus(modelItem.id, "1")
                if (dbResult.rowsAffected == 1) {
                    articleStatusChanged(modelItem, "1")
                }
            }
        }

        Label {
            // We want to show it only when view isn't initialized.
            visible: !articleModel && articleViewRoot.showEmptyPlaceholder
            anchors.centerIn: parent
            text: i18n.tr("Select article")
            fontSize: "large"
        }
    }

    //////////////////////////////////////////////      delegate for ListView
    Component {
        id: articleDelegate

        Flickable {
            id: scrollArea
            objectName: "articleview_flickable"

            clip: true

            width: rssListview.width
            height: rssListview.height

            contentWidth: width
            contentHeight: innerAreaColumn.height

            Column {
                id: innerAreaColumn

                spacing: units.gu(2)
                width: parent.width

                property int mediaDownloadInProgress: 0

                function mediaDownloaded() {
                    mediaDownloadInProgress = mediaDownloadInProgress - 1
                }

                Row {
                    width: parent.width - units.gu(4)
                    height: labelTime.paintedHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1)

                    Icon {
                        id: imgFavourite
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }
                        name: "favorite-selected"
                        visible: modelItem == null ? false : (modelItem.favourite == "1")
                    }

                    Label {
                        id: labelTime
                        text: DateUtils.formatRelativeTime(i18n, pubdate)
                        fontSize: "small"
                        width: parent.width - units.gu(3)
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }

                Label {
                    objectName: "articleviewitem_title"
                    fontSize: "large"
                    text: model.title
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Label {
                    color: "grey"
                    text: model.author ? model.author : ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: text !== "" && text !== '""'
                }

                Label {
                    text: model.content

                    fontSize: {
                        switch(rssListview.contentFontSize) {
                        case 0:
                            return "small"
                        case 1:
                            return "medium"
                        case 2:
                            return "large"
                        }
                    }
                    linkColor: "lightblue"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    clip: true

                    onLinkActivated: Qt.openUrlExternally(model.link)
                }

                Label {
                    id: label_feedname
                    text: model.feed_name ? model.feed_name : ""
                    fontSize: "small"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            } // Column

        } // Flickable
    } // Component

    Component {
        id: readingOptionsPopoverComponent
        ReadingOptions { }
    } // Comp
}
