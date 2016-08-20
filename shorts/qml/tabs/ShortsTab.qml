import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB

BaseTab {
    id: aShortsTab

    readonly property int __listModeCount: 8

    /* Tab will be reloaded if it wasn't activated before or if there is
     * well known purpose for it.
     */
    function reloadTab(purpose) {
        console.log("ShortsTab reloading:", topicId, __isActive, purpose)
        if (__isActive && !purpose)
            return

        clear()

        __isActive = true
        if (isListMode) {
            reloadList()
            listPage.reload()
        } else {
            reloadGrid()
            gridPage.reload()
        }
    }

    function clear() {
        gridPage.clear()
        listPage.clear()
        commonModelGrid.clear()
        commonModelList.clear()
    }

    function getModel() {
        if (isListMode)
            return commonModelList
        else return commonModelGrid
    }

    function getTagByFeed(feedTags, feedId) {
        for (var j = 0; j < feedTags.rows.length; j++) {
            var ft = feedTags.rows.item(j)
            if (ft.feed_id == feedId)
                return ft.tag_id
        }

        console.log("ERROR: getTagByFeed, feed without tag, feedId:", feedId)
    }

    function reloadList() {
        var tagArticles = DB.loadTagHighlights(__listModeCount)
        for (var j = 0; j < tagArticles.rows.length; j++) {
            var ca = tagArticles.rows.item(j)

            var articleObj = {"tagName" : ca.tag_name,
                "tagId" : ca.tag_id,
                "title" : ca.title,
                "content" : ca.content,
                "link" : ca.link,
                "author": ca.author,
                "description" : ca.description,
                "pubdate" : ca.pubdate,
                "status" : ca.status, // ?
                "favourite" : ca.favourite,
                "feedId" : ca.feed_id,
                "feed_name" : ca.feed_name,
                "image" : ca.image,
                "media_groups" : ca.media_groups,
                "id" : ca.id }

            commonModelList.append(articleObj)
        }
    }

    function reloadGrid() {
        var feedArticles = DB.loadArticles({"isAll": true})
        var feedTags = DB.loadFeedTags()

        var articlesToAppend = []
        for (var i = 0; i < feedArticles.rows.length; i++) {
            var cart = feedArticles.rows.item(i)

            var artObj = {"tagName" : "",
                "tagId" : getTagByFeed(feedTags, cart.feed_id),
                "title" : cart.title,
                "content" : cart.content,
                "link" : cart.link,
                "author": cart.author,
                "description" : cart.description,
                "pubdate" : cart.pubdate,
                "status" : cart.status,
                "favourite" : cart.favourite,
                "feedId" : cart.feed_id,
                "image" : cart.image,
                "feed_name" : cart.feed_name,
                "media_groups" : cart.media_groups,
                "id" : cart.id }

            articlesToAppend.push(artObj)
        }

        commonModelGrid.append(articlesToAppend)
    }

    ListModel {
        id: commonModelGrid
        objectName: "commonModelGrid"
    }

    ListModel {
        id: commonModelList
        objectName: "commonModelList"
    }
}
