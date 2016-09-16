import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "./pages"
import "./tabs"
import "./components"
import "./utils/databasemodule_v2.js" as DB

import "./content"
import "./nongoogle"

MainView {
    id: mainView

    objectName: "mainView"
    applicationName: "shorts-app.mrqtros"
    anchorToKeyboard: true

    width: units.gu(46)
    height: units.gu(84)
    focus: true

    Component.onCompleted: {
        QuickUtils.mouseAttached = true
        configureDb()
    }

    function configureDb() {
        var dbParams = {"isRefreshRequired" : false,
            "oldDbVersion" : optionsKeeper.dbVersion(),
            "newDbVersion" : ""
        }

        DB.adjustDb(dbParams)

        if (dbParams.oldDbVersion != dbParams.newDbVersion)
            optionsKeeper.setDbVersion(dbParams.newDbVersion)

        if (dbParams.isRefreshRequired) {
            topicManagement.reloadTopics()
            refresh()
        }

        reloadMainView()
    }

    /* Refresh current topic or all feeds if we are in the Shorts.
     */
    function refresh() {
        var topicId = pageStack.currentTopicId()
        console.log("Refresh", topicId)

        console.log("REFRESH TOPIC", topicId)
        if (topicId == -2) {
            refreshSavedTab()
            return
        }

        var feeds = topicId !== 0 ? DB.loadFeedsFromTag(topicId) : DB.loadFeeds()

        var feedarray = []
        for (var i = 0; i< feeds.rows.length; i++)
            feedarray.push(feeds.rows.item(i))
        networkManager.updateFeeds(feedarray, topicId)
    }

    function reloadViews(tagId) {
        tagId = tagId || 0

        if (tagId == 0)
            shortsTab.reloadTab("reloadViews")
        else topicTab.reloadTab("reloadViews")
    }

    function reloadMainView() {
        mainPage.reloadPageContent()
    }

    // refresh "Saved" Tab
    function refreshSavedTab() {
        savedTab.reloadTab()
    }

    function showArticle(model, index) {
        articlePage.setFeed(model, index)
        pageStack.push(articlePage, null, pageStack.useOrdinaryLayout)
    }

    // TODO BUG
    function editFeed(feedid, title, url, pTopicId, srcPage) {
        editFeed.setValues(feedid, title, url, pTopicId)
        pageStack.push(editFeed, srcPage)
    }

    /* -------------------------- Visuals ---------------------------- */
    AdaptivePageLayout {
        id: pageStack

        objectName: "pageStack"
        primaryPage: mainPage
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: -1 // SDK BUG?
        }
        focus: true

        property var commonHeadActions: [refreshAction, changeModeAction, nightModeAction]
        property bool useOrdinaryLayout: true
        property Page lastPushedPage: null  // Last page that was pushed to the first column of APL.

        // TODO Workaround.
        function currentTopicId() {
            return lastPushedPage && lastPushedPage.hasOwnProperty("topicId") ? lastPushedPage.topicId : 0
        }

        function push(page, sourcePage, toNext, props) {
            if (!page)
                return

            // Sanitize input.
            sourcePage = sourcePage || lastPushedPage || mainPage
            toNext = !!toNext

            // Add to appropriate column.
            if (toNext)
                pageStack.addPageToNextColumn(sourcePage, page, props)
            else pageStack.addPageToCurrentColumn(sourcePage, page, props)

            if (page.reloadPageContent)
                page.reloadPageContent()

            if (!toNext)
                lastPushedPage = page
        }

        function pop(page) {
            pageStack.removePages(page)
        }

        /* Used for keeping status in sync across tabs.
         */
        function updateStatusInModels(article, status) {
            var tagId = article.tagId
            var articleId = article.id

            savedTab.updateStatusInModel(articleId, status)
            shortsTab.updateStatusInModel(articleId, status)
            topicTab.updateStatusInModel(articleId, status)
        }

        /* Used for keeping favourite in sync across tabs.
         */
        function updateFavouriteInModels(article, fav) {
            var tagId = article.tagId
            var articleId = article.id

            savedTab.updateFavouriteInModel(article, fav) // SavedTab requires article object, not articleId.
            shortsTab.updateFavouriteInModel(articleId, fav)
            topicTab.updateFavouriteInModel(articleId, fav)
        }

        Keys.onPressed: {
            console.log(objectName, event.key.toString(16), event.modifiers.toString(16))

            // Refresh on F5.
            if (event.key === Qt.Key_F5)
                refresh()

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_A) {
                    pageStack.push(appendFeedPage, mainPage)
                } else if (event.key === Qt.Key_R) {
                    refresh()
                }
            }

            if (event.key == Qt.Key_Left) {
                articlePage.articleView.showPrevArticle()
            } else if (event.key == Qt.Key_Right) {
                articlePage.articleView.showNextArticle()
            }
        }

        /* -------------------------- Actions ---------------------------- */

        Action {
            id: refreshAction

            text:  i18n.tr("Refresh")
            iconName: "reload"
            onTriggered: refresh()
        }

        Action {
            id: changeModeAction
            text:  optionsKeeper.useListMode ? i18n.tr("Grid View") : i18n.tr("List view")
            iconName: optionsKeeper.useListMode ? "view-grid-symbolic" : "view-list-symbolic"
            onTriggered: {
                optionsKeeper.useListMode = !optionsKeeper.useListMode
            }
        }

        Action {
            id: nightModeAction
            objectName:"nightModeAction"
            text: optionsKeeper.useDarkTheme ? i18n.tr("Disable night mode") : i18n.tr("Enable night mode")
            iconName: "night-mode"
            onTriggered: {
                optionsKeeper.useDarkTheme = !optionsKeeper.useDarkTheme
            }
        }

        MainPage {
            id: mainPage

            objectName: "mainPage"
        }

        SavedTab {
            id: savedTab

            objectName: "Tab1"
            tabTitle: i18n.tr("Saved")
            topicId: -2
        }

        ShortsTab {
            id: shortsTab

            objectName: "Tab0"
            tabTitle: i18n.tr("Shorts")
            topicId: 0
        }

        TopicTab {
            id: topicTab

            objectName: "TopicTab"
        }

        // ******************************** Create Topic **********************///////////////

        CreateTopicPage {
            id: createTopicPage
            visible: false
            flickable: null
        } // Page

        // ******************************** APPEND FEED ***********************///////////////

        AppendFeedPage {
            id: appendFeedPage

            title: i18n.tr("Add feeds")
            flickable: null
            visible: false
        }

        AppendNGFeedPage {
            id: appendNGFeedPage

            title: i18n.tr("Add feeds")
            flickable: null
            visible: false
        }

        // ******************************** Choose Topic Page ***********************///////////////

        ChooseTopicPage {
            id: chooseTopicPage
            visible: false
        }

        // ******************************** Rss Feed Page ***********************///////////////

        ArticleViewPage {
            id: articlePage
            visible: false

            Connections {
                target: articlePage.articleView

                onArticleStatusChanged: pageStack.updateStatusInModels(article, status)
                onArticleFavouriteChanged: pageStack.updateFavouriteInModels(article, favourite)
            }
        }

        // ******************************** Topic Management Page ***********************///////////////
        TopicManagementPage {
            id: topicManagement
            visible: false
        }

        // ******************************** Settings Page ***********************///////////////
        SettingsPage {
            id: settingsPage
            visible: false
        }

        // ******************************** Edit Feed Page ***********************///////////////
        EditFeedPage {
            id: editFeed
            visible: false
        }

        // ******************************** Share Page ***********************///////////////
        SharePage {
            id: sharePage
            visible: false
        }

        // ******************************** Share Page ***********************///////////////
        YadLoginPage {
            id: yadLoginPage
            visible: false

            onAuthPassed: {
                console.log("TOKEN", token)

                optionsKeeper.yadToken = token
                // networkManager.token = token TODO
                pageStack.pop(yadLoginPage)
            }
        }
    } // PageStack

    /* -------------------------- Utils ---------------------------- */

    NetworkManager {
        id: networkManager

        onDownloadFinished: {
            reloadViews(tagId)
        }

        onDownloadStarted: {
            PopupUtils.open(refreshWaitDialogComponent, null)
        }
    }

    OptionsKeeper {
        id: optionsKeeper
    }

    // Positioner to detect current position
//    Positioner {
//        id: positionDetector
//    }

    /* -------------------------- Components ---------------------------- */

    Component {
        id: refreshWaitDialogComponent

        Dialog {
            id: refreshWaitDialog
            objectName: "refreshWaitDialog"

            title: i18n.tr("Checking for new articles")

            ActivityIndicator {
                objectName: "activityindicator"
                running: true
            }

            Button {
                text: i18n.tr("Cancel")
                objectName: "refreshCancel"
                color: UbuntuColors.orange
                onClicked: {
                    networkManager.cancelDownload()
                    PopupUtils.close(refreshWaitDialog)
                }
            }

            Connections {
                target: networkManager

                onDownloadFinished: {
                    PopupUtils.close(refreshWaitDialog)
                    if ( networkManager.operationStatus === "withErrors" ) {
                        PopupUtils.open(errorDialogComponent, pageStack,
                                        {"text" : i18n.tr("Perhaps some of the channels have not been updated."),
                                            "title" : i18n.tr("Errors occurred during the update")})
                    }
                }
            }
        } // Dialog
    } // Component

    Component {
        id: errorDialogComponent

        Dialog {
            id: errorDialog

            Button {
                text: i18n.tr("Ok")
                objectName: "errordialogbutton"
                onClicked: PopupUtils.close(errorDialog)
            }
        }
    } // Component

    ////////////////////////////////////////////////////////  a dialog to ask user if she/he wants to turn off the google search
    Component {
        id: componentDialogNG

        Dialog {
            id: dialogNG
            title: i18n.tr("Warning")
            text: i18n.tr("Shorts detects that you're located in an area which blocks Google's IP.<br><br>"
                          + "We strongly reconmend you to turn off the Google search funtion."
                          + "Or you can do it in the settings page manually.")

            Button {
                text: i18n.tr("Yes, please.")
                color: UbuntuColors.orange
                objectName: "dialogNGButtonYes"
                onClicked: {
                    optionsKeeper.setUseGoogleSearch(false)
                    PopupUtils.close(dialogNG)
                }
            }

            Button {
                text: i18n.tr("No, thanks.")
                objectName: "dialogNGButtonNo"
                onClicked: PopupUtils.close(dialogNG)
            }
        }
    } // Component

    /* -------------------------- Connections ---------------------------- */

    Connections {
        target: createTopicPage

        onTopicAdded: {
            //reloadViews()
            reloadMainView()
        }
    }

    Connections {
        target: chooseTopicPage

        onTopicChoosen: {
            mainPage.bottomEdge.collapse()
            networkManager.updateFeeds(addedFeeds, topicId)
            reloadMainView()
        }
    }

    Connections {
        target: topicManagement

        onFeedEdit: {
            console.log("onFeedEdit: ", topicId)
            reloadMainView()
        }

        onTopicDeleted: {
            reloadMainView()
        }
    }

    // Shader workaround.
    Rectangle {
        z: -1
        anchors.fill: parent
    }

    layer.effect: DarkModeShader {}
    layer.enabled: optionsKeeper.useDarkTheme
}
