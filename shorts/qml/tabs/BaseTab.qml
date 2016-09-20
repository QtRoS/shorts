import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../components"
import "../utils/databasemodule_v2.js" as DB

Page {
    id: baseTab

    property bool isListMode: optionsKeeper.useListMode
    property int topicId: -1

    property Item listPage: listModePage
    property Item gridPage: gridModePage

    /* Tab displays its contents only when selected. */
    property bool __isActive: false

    property alias tabTitle: pageHeader.title

    onIsListModeChanged: modeChangeHandler()

    header: PageHeader {
        id: pageHeader

        trailingActionBar.actions: [
            Action {
                id: refreshAction

                text:  i18n.tr("Refresh")
                iconName: "reload"
                onTriggered: mainView.refresh()
            },
            Action {
                id: changeModeAction
                text:  optionsKeeper.useListMode ? i18n.tr("Grid View") : i18n.tr("List view")
                iconName: optionsKeeper.useListMode ? "view-grid-symbolic" : "view-list-symbolic"
                onTriggered: {
                    optionsKeeper.useListMode = !optionsKeeper.useListMode
                }
            },
            Action {
                id: nightModeAction
                objectName:"nightModeAction"
                text: optionsKeeper.useDarkTheme ? i18n.tr("Disable night mode") : i18n.tr("Enable night mode")
                iconName: "night-mode"
                onTriggered: {
                    optionsKeeper.useDarkTheme = !optionsKeeper.useDarkTheme
                }
            }
        ]
    }

    ListModeItem {
        id: listModePage

        visible: isListMode
        anchors {
            left: parent.left
            top: pageHeader.bottom
            right: parent.right
            bottom: parent.bottom
        }
        topicId: baseTab.topicId
    }

    GridModeItem {
        id: gridModePage

        visible: !isListMode
        anchors {
            left: parent.left
            top: pageHeader.bottom
            right: parent.right
            bottom: parent.bottom
        }
        topicId: baseTab.topicId
    }

    function modeChangeHandler() {
        if (topicId == -1 || !__isActive) // Ignore first undefined state.
            return

        reloadTab("modeChangeHandler")
    }

    /* Tab will be reloaded if it wasn't activated before or if there is
     * well known purpose for it.
     */
    function reloadTab(purpose) {
        console.log("BaseTab reloading:", topicId, __isActive, purpose)
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
        var topicArticles = DB.loadArticles({"tagId" : topicId})

        for (var j = 0; j < topicArticles.rows.length; j++) {
            var ca = topicArticles.rows.item(j)

            var anObj = {"tagName" : "",
                "tagId" : topicId,
                "title" : ca.title,
                "content" : ca.content,
                "link" : ca.link,
                "author": ca.author,
                "description" : ca.description,
                "pubdate" : ca.pubdate,
                "status" : ca.status, // ?
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

    function clear() {
        __isActive = false
        gridPage.clear()
        listPage.clear()
        getModel().clear()
    }

    /* All views should use this method to access shared model.
     */
    function getModel() {
        return commonSharedModel
    }

    function updateStatusInModel(articleId, status) {
        var usedModel = getModel()

        for ( var i = 0; i < usedModel.count; i++) {
            if (usedModel.get(i).id === articleId) {
                usedModel.get(i).status = status
                break
            }
        }
    }

    function updateFavouriteInModel(articleId, fav) {
        var usedModel = getModel()

        for ( var i = 0; i < usedModel.count; i++) {
            if (usedModel.get(i).id === articleId) {
                usedModel.get(i).favourite = fav
                break
            }
        }
    }

    ListModel {
        id: commonSharedModel
    }

    Label {
        id: lblEmptyBase

        text: i18n.tr("There are no articles to show")
        visible: getModel().count === 0
        anchors.centerIn: parent
        fontSize: "large"
    }
}
