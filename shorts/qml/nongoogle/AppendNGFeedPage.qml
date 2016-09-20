/*
 * Copyright (C) 2013, 2014, 2015, 2016
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB
import "../."

Page {
    id: appendNgFeedPage

    objectName: "appendNgFeedPage"
    flickable: null
    visible: false

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Add feeds")

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text:  i18n.tr("Cancel")

                onTriggered: {
                    xmlFeedApi.abort()
                    pageStack.pop(appendNgFeedPage)
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "ok"
                text: i18n.tr("Next")
                enabled: !xmlFeedApi.inProgress && feedUrl != "" && feedTitle != ""

                onTriggered: {
                    var selectedFeeds = [feedObj]
                    pageStack.push(chooseTopicPage, appendNgFeedPage, false, {"feedsToAdd" : selectedFeeds, "parentPage" : appendNgFeedPage})
                }
            }
        ]
    }

    property int selectedCount: 0
    property bool resultsReceived: false // Indicates that at least once results were received.

    function reloadPageContent() {
    }

    /* Clear model and model's depend data.
     * Currently only selectedCount.
     */
    function clearModelDependData() {
//        searchResultsModel.clear()
//        selectedCount = 0
    }

    // -------------------------------------       XmlNetwork

    property string feedTitle: ""
    property string feedDesc: ""
    property string feedUrl: ""
    property string feedLink: ""
    property var feedObj

    XmlNetwork {
        id: xmlFeedApi

        onLoadResult: {
            if (!result.rss) {
                print("onLoadResult failed")
            }
            else {
                var f = result.rss.channel

                feedDesc = f.description ? (f.description["#text"] ? f.description["#text"] : f.description ) : ""
                feedTitle = f.title ? (f.title["#text"] ? f.title["#text"] : f.title ) : ""
                feedLink = f.link ? (f.link["#text"] ? f.link["#text"] : f.link) : ""
                feedObj = {
                    "url" : feedUrl,
                    "title" : feedTitle,
                    "description" : feedDesc,
                    "link" : feedLink
                }
            }
        }
    }

    // -------------------------------------       XmlNetwork

    Column {
        id: appendFeedColumn

        anchors.top: parent.top
        anchors.topMargin: units.gu(2)
        width: parent.width
        spacing: units.gu(2)

        TextField {
            objectName: "tfFeedUrl"
            id: tfFeedUrl

            placeholderText: i18n.tr("Type a keyword or URL")

            width: parent.width - units.gu(4)
            // height:units.gu(5)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            primaryItem: Icon {
                height: parent.height*0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                name: "search"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (Qt.inputMethod.visible)
                            tfFeedUrl.accept()
                    }
                }
            }

            onAccepted: accept()

            function accept() {
                Qt.inputMethod.hide()
                var userInput = text

                if (!userInput)
                    return

                // Very simple logic, URL if there are no spaces and contains dots.
                // But simple not means that it is wrong.
                var isUrlEntered = (userInput.indexOf(" ") === -1 && userInput.indexOf(".") !== -1)

                if (isUrlEntered) {
                    if (userInput.indexOf("http://") !== 0)
                    {userInput = "http://" + userInput}
                    feedUrl = userInput
                    xmlFeedApi.loadFeed(userInput)
                }
//                else xmlFeedApi.findFeeds(text)
                else {
                    // TODO  alert that user input invalid
                    print("input invalid")
                }
            }
        }

        ListItem.Header {

            ListItem.ThinDivider { }

            text: i18n.tr("Feed Title:")

            ListItem.ThinDivider { anchors.bottom: parent.bottom }
        }

        Label {
            anchors { left: parent.left;right: parent.right; margins: units.gu(2) }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: feedTitle == "" ? i18n.tr("No data") : feedTitle
        }

        ListItem.Header {

            ListItem.ThinDivider { }

            text: i18n.tr("Feed Description:")

            ListItem.ThinDivider { anchors.bottom: parent.bottom }
        }

        Label {
            anchors { left: parent.left;right: parent.right; margins: units.gu(2) }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: feedDesc == "" ? i18n.tr("No data") : feedDesc
        }
    } // Column
}
