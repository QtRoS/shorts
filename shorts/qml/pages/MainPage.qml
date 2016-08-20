import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../components"
import "../utils/databasemodule_v2.js" as DB
import "../."

Page {
    id: mainPage

    objectName: "mainpage"
    flickable: null
    visible: true

    header: PageHeader {
        visible: false
    }

    Item {
        id: pageHeader

        height: units.gu(6)
        anchors {
            right: parent.right
            left: parent.left
        }

        Row {
            spacing: units.gu(0.5)
            anchors {
                right: parent.right
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }

            ActionIcon {
                id: actionSetting
                objectName:"actionSetting"
                icon.name: "settings"
                onClicked: pageStack.push(settingsPage, mainPage)
            }

            ActionIcon {
                id: editTopicsAction
                objectName:"editTopicsAction"
                icon.name: "edit"
                onClicked: pageStack.push(topicManagement, mainPage)
            }
        }
    }

    function reloadPageContent() {
        var tags = DB.loadTags()
        topicModel.clear()
        for (var i = 0; i< tags.rows.length; i++) {
            topicModel.append({ "title" : tags.rows.item(i).name,
                                  "topicId" : tags.rows.item(i).id })
        }
    }

    function showTopicById(topicId, topicTitle) {
        console.log("ShowTopicById", topicId)
        var pageToAdd
        if (topicId == 0)
            pageToAdd = shortsTab
        else if (topicId == -1)
            pageToAdd = savedTab
        else {
            topicTab.topicId = topicId
            topicTab.tabTitle = topicTitle
            pageToAdd = topicTab
        }

        pageToAdd.reloadTab("selectedInMainPage")
        pageStack.push(pageToAdd, mainPage)
    }

    ListView {
        id: topicList
        objectName: "topiclist"

        clip: true
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: pageHeader.bottom
        }

        model: topicModel

        header: Item {
            id: mainButtonsRow

            height: units.gu(10)
            anchors {
                left: parent.left
                right: parent.right
            }

            Rectangle {
                id: shortsBtn

                border.color: "#21b8e9"
                color: shortsBtnMa.pressed ? "#4ec6ee" : "#00000000"

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.horizontalCenter
                    rightMargin: units.gu(1)
                    top: parent.top
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }

                Text {
                    anchors.centerIn: parent
                    text: i18n.tr("Shorts")
                }

                MouseArea {
                    id: shortsBtnMa
                    anchors.fill: parent
                    onClicked: showTopicById(0)
                }
            }


            // ------------------------------------------

            // ==================================================

            Rectangle {
                id: savedBtn

                border.color: "#21b8e9"
                color: savedBtnMa.pressed ? "#4ec6ee" : "#00000000"

                anchors {
                    left: parent.horizontalCenter
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(2)
                    top: parent.top
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }

                Text {
                    anchors.centerIn: parent
                    text: i18n.tr("Saved")
                }

                MouseArea {
                    id: savedBtnMa
                    anchors.fill: parent
                    onClicked: showTopicById(-1)
                }
            }

            // ==================================================
        }

        delegate: Item {

            height: units.gu(8)
            anchors {
                right: parent.right
                left: parent.left
            }

            Rectangle {

                border.color: "#21b8e9"
                color: delMa.pressed ? "#4ec6ee" : "#00000000"

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                    top: parent.top
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }

                Label {
                    anchors.centerIn: parent
                    width: parent.width - units.gu(2)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    text: model.title
                }

                MouseArea {
                    id: delMa
                    anchors.fill: parent
                    onClicked: showTopicById(model.topicId, model.title)
                }
            }

        }
    }

    ListModel {
        id: topicModel
    }

    Label {
        visible: topicModel.count == 0
        anchors.centerIn: parent
        text: i18n.tr("No topics")
        fontSize: "large"
    }
}
