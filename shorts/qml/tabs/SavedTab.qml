import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB

BaseTab {
    id: aSavedTab

    function modeChangeHandler() {
        if (topicId == -1 || !__isActive) // Ignore first undefined state.
            return

        reloadTab("modeChangeHandler")
    }

    /* Tab will be reloaded if it wasn't activated before or if there is
     * well known purpose for it.
     */
    function reloadTab(purpose) {
        console.log("SavedTab reloading:", topicId, __isActive, purpose)
        if (__isActive && !purpose)
            return

        reloadInternal()
        __isActive = true
        if (isListMode)
            listPage.reload()
        else gridPage.reload()
    }

    function reloadInternal() {
        clear()

        var articlesByTopic = []
        var topicArticles = DB.loadFavouriteArticles()

        for (var j = 0; j < topicArticles.rows.length; j++) {
            var ca = topicArticles.rows.item(j)

            var anObj = {"tagName" : "",
                "tagId" : ca.tag_id,
                "title" : ca.title,
                "content" : ca.content,
                "link" : ca.link,
                "author": ca.author,
                "description" : ca.description,
                "pubdate" : ca.pubdate,
                "status" : ca.status,
                "favourite" : ca.favourite,
                "feedId" : ca.feed_id,
                "image" : ca.image,
                "feed_name" : ca.feed_name,
                "media_groups" : ca.media_groups,
                "id" : ca.id }

            articlesByTopic.push(anObj)
        }

        // Sort for list mode.
        if (isListMode) {
            articlesByTopic.sort(function(a,b) {
                if (a.feedId === b.feedId)
                    return b.pubdate - a.pubdate
                else return b.feedId - a.feedId
            })
        }

        var commonModel = getModel()
        commonModel.append(articlesByTopic)
    }

    function updateFavouriteInModel(article, fav) {
        if (fav == "1")
            appendArticle(article)
        else removeArticle(article)
    }

    function removeArticle(article) {
        var commonModel = getModel()
        var articleId = article.id
        for ( var i = 0; i < commonModel.count; i++) {
            if (commonModel.get(i).id == articleId) {
                commonModel.get(i).favourite = "0"
                break
            }
        }
    }

    function appendArticle(article) {
        var commonModel = getModel()
        var articleId = article.id
        /* Check if article already exist in model.
         */
        for ( var i = 0; i < commonModel.count; i++) {
            if (commonModel.get(i).id == articleId) {
                commonModel.get(i).favourite = "1"
                return
            }
        }

        /* Copying object is better than share, more robust.
         */
        var anObj = {"tagName" : article.tagName,
            "tagId" : article.tagId,
            "title" : article.title,
            "content" : article.content,
            "link" : article.link,
            "description" : article.description,
            "pubdate" : article.pubdate,
            "status" : article.status, // ?
            "favourite" : "1" /*article.favourite*/,
            "feedId" : article.feedId,
            "image" : article.image,
            "feed_name" : article.feed_name,
            "media_groups" : article.media_groups,
            "id" : article.id }

        if (!isListMode) {
            commonModel.append(anObj)
            gridPage.triggerLoadMore()
        } else {
            /* Cycle need to insert new item in correct place
             * to preserve right sections.
             */
            var j = 0
            for (; j < commonModel.count; j++) {
                if (commonModel.get(j).feedId == anObj.feedId) {
                    commonModel.insert(j, anObj)
                    break
                }
            }

            /* If no such section, simply append new item.
             */
            if (j == commonModel.count)
                commonModel.append(anObj)
        }
    }
}
