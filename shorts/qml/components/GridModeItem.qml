import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../utils/dateutils.js" as DateUtils

Item {
    id: gridPage

    property int topicId: 0
    property var gridViewModel: null

    function reload () {
        gridViewModel = getModel()
        //organicGridView.reload()
    }

    function clear() {
        gridViewModel = null
        //organicGridView.clear()
    }

    //    function triggerLoadMore() {
    //        organicGridView.loadMore()
    //    }

    //    OrganicGrid {
    //        id: organicGridView
    //    }

    Component {
        id: gridModeDelegate

        Item {
            width: units.gu(26)
            height: units.gu(22)

            Rectangle {
                id: articleFullImg

                property bool invalid: false
                property var modelItem
                property var rssModel
                property int modelIndex

                width: units.gu(24)
                height: units.gu(20)
                anchors.centerIn: parent
                color: model.status == "1" ? "#e5e4e5" : "#D6BCD3"

//                border {
//                    width: units.dp(2)
//                    color: (model.status == "1" ? "lightgrey" : "#EB6536")
//                }

                Rectangle {
                    z: -1
                    width: parent.width
                    height: parent.height
                    x: units.gu(0.6)
                    y: units.gu(0.6)
                    color: model.status == "1" ? "#aacccccc" : "#F1E8F0"
                }

                Item {
                    id: uPic

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: pic.height //  > (articleFullImg.height * 0.46) ? (articleFullImg.height * 0.46) : pic.height
                    opacity: height
                    Image {
                        id: pic
                        fillMode: Image.PreserveAspectCrop
                        width: (implicitHeight < 50 || implicitWidth < 50) ? 0 : parent.width
                        height:  implicitHeight > (articleFullImg.height * 0.46) ? (articleFullImg.height * 0.46) : implicitHeight
                        source: model.image ? model.image : ""
                        sourceSize.width: uPic.width
                    }

                    Behavior on height { UbuntuNumberAnimation {} }
                    Behavior on opacity { UbuntuNumberAnimation {} }
                }

                Row {
                    id: timeRow
                    anchors {
                        top: uPic.bottom
                        topMargin: units.gu(1)
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    height: labelTime.height
                    spacing: units.gu(0.5)

                    Icon {
                        id: imgFavourite
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }
                        name: "favorite-selected"
                        visible: (model.favourite == "1")
                    }

                    Label {
                        id: labelTime
                        text: { DateUtils.formatRelativeTime(i18n, model.pubdate) }
                        fontSize: "x-small"
                        width: parent.width - units.gu(1)
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        opacity: 0.8
                    }
                }

                Label {
                    id: labelTitle

                    text: model.title
                    anchors {
                        top: timeRow.bottom
                        topMargin: units.gu(1)
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                        bottom: labelFeedname.top
                    }
                    height: units.gu(4.8)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    fontSize: "small"
                    textFormat: Text.PlainText
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    opacity: (model.status == "1" ? 0.8 : 1)
                }

                Label {
                    id: labelFeedname
                    text: model.feed_name
                    fontSize: "x-small"
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    opacity: 0.8
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mainView.showArticle(gridViewModel, model.index)
                    }
                }
            }
        }
    }

    //    Component {
    //        id: gridModeDelegate

    //        ListItem {
    //            id: listItem

    //            property bool useNoImageIcon: !model.image

    //            height: units.gu(20)
    //            onClicked: mainView.showArticle(listViewModel, model.index)


    //            ListItemLayout {
    //                anchors.fill: parent

    //                Rectangle {
    //                    id: uPic

    //                    SlotsLayout.position: SlotsLayout.Leading
    //                    SlotsLayout.overrideVerticalPositioning: true

    //                    y: units.gu(2)
    //                    height: units.gu(14) + units.dp(4)
    //                    width: units.gu(14) + units.dp(4)
    //                    color: "transparent"
    //                    border {
    //                        width: units.dp(2)
    //                        color: listItem.useNoImageIcon || pic.status == Image.Loading ? "transparent" : (model.status == "1" ? "lightgrey" : "#EB6536")
    //                    }

    //                    Image {
    //                        id: pic

    //                        fillMode: Image.PreserveAspectCrop
    //                        height: units.gu(14)
    //                        width: units.gu(14)
    //                        sourceSize {
    //                            width: height * 2
    //                            //height: units.gu(20)
    //                        }

    //                        source: selectIcon()
    //                        anchors.centerIn: parent

    //                        function selectIcon() {
    //                            var img = model.image
    //                            return !model.image ? "" : model.image
    //                        }

    //                        Behavior on height { UbuntuNumberAnimation{} }
    //                        Behavior on opacity { NumberAnimation{} }


    //                        ActivityIndicator {
    //                            id: loadingIndicator
    //                            anchors.centerIn: parent
    //                            running: pic.status == Image.Loading
    //                            visible: running
    //                        }
    //                    }

    //                    Icon {
    //                        anchors.centerIn: parent
    //                        visible: listItem.useNoImageIcon && !loadingIndicator.running
    //                        color: model.status == "1" ? "lightgrey" : "#EB6536"
    //                        name: "ubuntu-logo-symbolic"
    //                        width: units.gu(6)
    //                        height: units.gu(6)
    //                    }
    //                }

    //                Icon {
    //                    id: imgFavourite
    //                    SlotsLayout.position: SlotsLayout.Trailing
    //                    width: units.gu(2); height: width
    //                    name: "favorite-selected"
    //                    visible: model.favourite == "1"
    //                }

    //                title {
    //                    text: model.title
    //                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    //                    fontSize: "small"
    //                    textFormat: Text.PlainText
    //                    font.weight: Font.DemiBold
    //                    elide: Text.ElideRight
    //                    maximumLineCount: 3
    //                }

    //                subtitle {
    //                    text: model.content //model.feed_name
    //                    fontSize: "x-small"
    //                    textFormat: Text.PlainText
    //                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    //                    elide: Text.ElideRight
    //                    maximumLineCount: 5
    //                }

    //                summary {
    //                    text: DateUtils.formatRelativeTime(i18n, model.pubdate)
    //                    fontSize: "x-small"
    //                    textFormat: Text.PlainText
    //                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    //                }
    //            }

    //            Rectangle {
    //                color: "#EB6536"
    //                width: units.gu(0.5)
    //                visible: model.status != "1"
    //                anchors {
    //                    right: parent.right
    //                    top: parent.top
    //                    bottom: parent.bottom
    //                }
    //            }

    //        } //ListItem
    //    } // Component

    GridView {
        id: articleGrid

        clip: true
        flow: GridView.FlowTopToBottom
        anchors {
            fill: parent
//            leftMargin: units.gu(1)
//            topMargin: units.gu(1)
        }

        model: gridViewModel
        cellWidth: units.gu(26)
        cellHeight: units.gu(22)

        delegate: gridModeDelegate
    } // GridView
}
