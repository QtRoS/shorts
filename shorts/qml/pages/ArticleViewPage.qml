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

import "../components"
import "../utils/dateutils.js" as DateUtils
import "../utils/databasemodule_v2.js" as DB

Page {
    id: pageRoot
    objectName: "rssfeedpage"

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Feed")

        trailingActionBar.actions: [
            Action {
                text:  i18n.tr("Open site")
                iconName: "go-to"
                onTriggered: {
                    Qt.openUrlExternally(innerArticleView.modelItem.link)
                }
            },

            Action {
                text: !innerArticleView.modelItem ? "" : (innerArticleView.modelItem.favourite == "0" ? i18n.tr("Save") : i18n.tr("Remove"))
                iconName: (!innerArticleView.modelItem || innerArticleView.modelItem.favourite == "0") ?
                              "favorite-unselected" : "favorite-selected"
                onTriggered: {
                    var fav = (innerArticleView.modelItem.favourite == "0" ? "1" : "0")
                    var dbResult = DB.updateArticleFavourite(innerArticleView.modelItem.id, fav)
                    if (dbResult.rowsAffected === 1) {
                        innerArticleView.articleFavouriteChanged(innerArticleView.modelItem, fav)
                    }
                }
            },

            Action {
                text:  i18n.tr("Share...")
                iconName: "share"
                onTriggered: {
                    sharePageLoader.doAction(function(page) {
                        pageStack.push(page, pageRoot, false, { "articleUrl" : innerArticleView.modelItem.link } )
                    }) //pageStack.push(sharePage, pageRoot, false, { "articleUrl" : innerArticleView.modelItem.link } )
                }
            },

            Action {
                text:  i18n.tr("Options")
                iconName: "settings"
                onTriggered: {
                    PopupUtils.open(readingOptionsPopoverComponent, fakeItem)
                }
            }
        ]
    }

    property alias articleView: innerArticleView

    function setFeed(model, index) {
        innerArticleView.setFeed(model, index)
        pageHeader.title = innerArticleView.feedTitle
    }

    ArticleViewItem {
        id: innerArticleView

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: pageHeader.bottom
        }
    }

    // This fake item is used for centering Options popup.
    Item { id: fakeItem; anchors.centerIn: innerArticleView }

    Component {
        id: readingOptionsPopoverComponent
        ReadingOptions { }
    } // Comp
}


