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

        ListItem {
            id: listItem

            property bool useNoImageIcon: !model.image

            height: units.gu(18)
            onClicked: mainView.showArticle(listViewModel, model.index)


            ListItemLayout {
                anchors.fill: parent

                Rectangle {
                    id: uPic

                    SlotsLayout.position: SlotsLayout.Leading
                    SlotsLayout.overrideVerticalPositioning: true

                    anchors.verticalCenter: parent.verticalCenter
                    height: units.gu(12)
                    width: units.gu(12)
                    color: "transparent"
                    border {
                        width: units.dp(1)
                        color: listItem.useNoImageIcon || pic.status == Image.Loading ? "transparent" : (model.status == "1" ? "lightgrey" : "#EB6536")
                    }

                    Image {
                        id: pic

                        fillMode: Image.PreserveAspectCrop
                        anchors {
                            fill: parent
                            margins: units.dp(1)
                        }

                        sourceSize {
                            width: height * 2
                            //height: units.gu(20)
                        }

                        source: selectIcon()
                        anchors.centerIn: parent

                        function selectIcon() {
                            var img = model.image
                            return !model.image ? "" : model.image
                        }

                        Behavior on height { UbuntuNumberAnimation{} }
                        Behavior on opacity { NumberAnimation{} }


                        ActivityIndicator {
                            id: loadingIndicator
                            anchors.centerIn: parent
                            running: pic.status == Image.Loading
                            visible: running
                        }
                    }

                    Icon {
                        anchors.centerIn: parent
                        visible: listItem.useNoImageIcon && !loadingIndicator.running
                        color: model.status == "1" ? "lightgrey" : "#EB6536"
                        name: "ubuntu-logo-symbolic"
                        width: units.gu(6)
                        height: units.gu(6)
                    }
                }

                Icon {
                    id: imgFavourite
                    SlotsLayout.position: SlotsLayout.Trailing
                    width: units.gu(2); height: width
                    name: "favorite-selected"
                    visible: model.favourite == "1"
                }

                title {
                    id: txtTitle
                    text: model.title
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    fontSize: "small"
                    textFormat: Text.PlainText
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }

                subtitle {
                    text: model.content
                    fontSize: "x-small"
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: txtTitle.lineCount > 1 ? 4 : 5
                }

                summary {
                    text: DateUtils.formatRelativeTime(i18n, model.pubdate)
                    fontSize: "x-small"
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }

            Rectangle {
                color: "#EB6536"
                width: units.gu(0.5)
                visible: model.status != "1"
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
            }

        } //ListItem
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

                    if (!listViewModel)
                        return ""

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
