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
    }

    function clear() {
        gridViewModel = null
    }

    Component {
        id: gridModeDelegate

        Item {
            width: articleGrid.cellWidth
            height: articleGrid.cellHeight

            Rectangle {
                id: articleFullImg

                width: parent.width - units.gu(2)
                height: parent.height - units.gu(2)
                anchors.centerIn: parent

                border {
                    width: units.dp(1)
                    color: model.status == "1" ? "lightgrey" : "#EB6536"
                }

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
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.dp(1)
                    }
                    height: pic.height
                    opacity: height
                    Image {
                        id: pic
                        fillMode: Image.PreserveAspectCrop
                        width: parent.width
                        height:  implicitHeight > (articleFullImg.height * 0.46) ? (articleFullImg.height * 0.46) : implicitHeight
                        source: model.image ? model.image : ""
                        sourceSize.width: units.gu(26) * 1.5
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

    GridView {
        id: articleGrid

        clip: true
        flow: GridView.FlowTopToBottom
        anchors.fill: parent
        model: gridViewModel
        delegate: gridModeDelegate
        cellWidth: units.gu(26)

        onHeightChanged: {
            var baseHeight = units.gu(22)
            var smallItemHeight = Math.floor(0.85 * baseHeight)
            var fitAmount = Math.floor(height / smallItemHeight)
            fitAmount = fitAmount || 1 // Boilerplate code.
            cellHeight = Math.floor( 1.0 * height / fitAmount)
        }
    } // GridView
}
