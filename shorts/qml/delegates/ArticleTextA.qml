import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../utils/dateutils.js" as DateUtils

//UbuntuShape
Rectangle
{
    id: articleTextA

    property bool invalid: false
    property var modelItem
    property var rssModel
    property int modelIndex

    // property string secretProp: ""

    width: units.gu(11)
    height: units.gu(20) /*content.height + units.gu(4)*/

//    color: invalid ? "black" : modelItem.status == "1" ? "#55cccccc" : "#5533b5e5"
    color: invalid ? "black" : modelItem.status == "1" ? "#e5e4e5" : "#b0dded"


    onModelItemChanged: {
        if (modelItem == null) {
            invalid = true
        }
    }

    Rectangle {
        z: -1
        width: parent.width
        height: parent.height
        x: units.gu(0.6)
        y: units.gu(0.6)
        color: invalid ? "black" : modelItem.status == "1" ? "#aacccccc" : "#3333b5e5"
    }

    Column {
        id: content

        anchors {
            fill: parent; topMargin: units.gu(1); bottomMargin: units.gu(1);
            leftMargin: units.gu(1); rightMargin: units.gu(1.5)
        }
        spacing: units.gu(1)

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
                visible: invalid ? false : (modelItem.favourite == "1")
            }

            Label {
                id: labelTime
                text: { invalid ? "" : DateUtils.formatRelativeTime(i18n, modelItem.pubdate) }
                fontSize: "x-small"
                width: parent.width - units.gu(2)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                opacity: 0.8
            }
        }

        Label {
            id: labelTitle

            text: invalid ? "" : modelItem.title
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
            opacity: invalid ? 0.4 : modelItem.status == "1" ? 0.8 : 1
        }

        Label {
            id: labelFeedname

            text: invalid? "" : modelItem.feed_name
            fontSize: "x-small"
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            opacity: 0.8
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mainView.showArticle(rssModel, modelIndex)
        }
    }
}

