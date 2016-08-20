import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Popups 1.3

import "../utils/dateutils.js" as DateUtils

Item {
    id: pageItself

    property int topicId: 0
    property var listViewModel: null
    property bool isShorts: topicId == 0

    function reload() {
        listViewModel = getModel()
    }

    function clear() {
        listViewModel = null
    }

    Component {
        id: listModeDelegate

        Item {
            id: readIndicator

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(12)

            Rectangle {
                id: listItem
                objectName: "feedlistitems"

                property bool useNoImageIcon: (pic.width == 0 || !model.image)

                color: model.status == "1" ? "#e5e4e5" : "#b0dded"
                anchors {
                    fill: parent
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }

                Rectangle {
                    z: -1
                    width: parent.width
                    height: parent.height
                    x: units.gu(0.6)
                    y: units.gu(0.6)
                    color: model.status == "1" ? "#aacccccc" : "#3333b5e5"
                }

                Item {
                    id: uPic

                    height: parent.height
                    width: pic.width
                    opacity: height
                    Image {
                        id: pic
                        height: {
                            if (implicitHeight < 50 || implicitWidth < 50)
                                return 0
                            else return uPic.height

                        }
                        width: height
                        source: selectIcon()
                        sourceSize.width: uPic.height * 2

                        function selectIcon() {
                            var img = model.image
                            return !model.image ? "" : model.image
                        }
                    }

                    Behavior on height { UbuntuNumberAnimation{} }
                    Behavior on opacity { NumberAnimation{} }
                }

                ActivityIndicator {
                    id: loadingIndicator
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(4)
                    }
                    running: pic.status == Image.Loading
                    visible: running
                }

                /* Ubuntu logo for articles without an image.
                     */
                Image {
                    anchors.centerIn: loadingIndicator
                    visible: listItem.useNoImageIcon && !loadingIndicator.running
                    source: Qt.resolvedUrl("/img/qml/icons/dash-home.svg")
                    width: units.gu(6)
                    height: units.gu(6)
                }

                Column {
                    id: content

                    anchors {
                        fill: parent; topMargin: units.gu(0.5); bottomMargin: units.gu(0.5);
                        leftMargin: listItem.height + units.gu(1.5); rightMargin: units.gu(1.5)
                    }
                    spacing: units.gu(0.8)

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: labelTime.paintedHeight
                        spacing: units.gu(0.5)

                        Icon {
                            id: imgFavourite
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                            }
                            name: "favorite-selected"
                            visible: model.favourite == "1"
                        }

                        Label {
                            id: labelTime
                            text: DateUtils.formatRelativeTime(i18n, model.pubdate)
                            fontSize: "x-small"
                            width: parent.width - units.gu(2)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            opacity: 0.6
                        }
                    } // Row

                    Label {
                        id: labelTitle
                        objectName: "label_title"

                        text: model.title
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: parent.height - parent.spacing * 2 - labelTime.paintedHeight - labelFeedname.paintedHeight
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        fontSize: "small"
                        textFormat: Text.PlainText
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        opacity: model.status == "1" ? 0.4 : 0.8
                    }

                    Label {
                        id: labelFeedname
                        objectName: "labelFeedname"

                        text: model.feed_name
                        fontSize: "x-small"
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        opacity: 0.6
                    }
                } // Column

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainView.showArticle(listViewModel, model.index)
                }
            }
        } //Rectangle
    } // Component

    ListView {
        id: articleList

        clip: true
        //width: mainView.isTabletMode ? units.gu(50) : parent.width
        //height: parent.height
        anchors.fill: parent
        visible: true
        model: listViewModel

        delegate: listModeDelegate

        section {
            criteria: ViewSection.FullString
            property: isShorts ? "tagId" : "feedId"
            // labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels

            delegate: ListItems.Standard {

                ListItems.ThinDivider {}

                height: units.gu(5)
                text: textBySection()

                function textBySection() {
                    var s = section

                    if (listViewModel == null) {
                        return ""
                    }

                    if (isShorts) {
                        for (var i = 0; i < listViewModel.count; i++) {
                            if (listViewModel.get(i).tagId == s) {
                                return listViewModel.get(i).tagName
                            }
                        }
                    } else {
                        for (var i = 0; i < listViewModel.count; i++) {
                            if (listViewModel.get(i).feedId == s) {
                                return listViewModel.get(i).feed_name
                            }
                        }
                    }

                    return ""
                }
            }
        } // section
    } // ListView
} // Page
