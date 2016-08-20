import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../utils/dateutils.js" as DateUtils

//UbuntuShape
Rectangle
{
    id: articleFullImg

    property bool invalid: false
    property var modelItem
    property var rssModel
    property int modelIndex

    // property string secretProp: ""

    width: units.gu(24)
    height: units.gu(20)
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
            source: invalid ? "" : modelItem.image
            sourceSize.width: uPic.width
        }

        Behavior on height { UbuntuNumberAnimation{} }
        Behavior on opacity { NumberAnimation{} }
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
            visible: invalid ? false : (modelItem.favourite == "1")
        }

        Label {
            id: labelTime
            text: { invalid ? "" : DateUtils.formatRelativeTime(i18n, modelItem.pubdate) }
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

        text: invalid? "" : modelItem.title
        anchors {
            top: timeRow.bottom
            topMargin: units.gu(1)
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: labelFeedname.top
        }
        height: units.gu(4.8) //parent.height - parent.spacing * 2 - labelTime.paintedHeight - label_feedname.paintedHeight
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        fontSize: "small"
        textFormat: Text.PlainText
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        opacity: invalid? 0.4 : (modelItem.status == "1" ? 0.8 : 1)
    }

    Label {
        id: labelFeedname
        text: invalid? "" : modelItem.feed_name
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
            mainView.showArticle(rssModel, modelIndex)
        }
    }
}
