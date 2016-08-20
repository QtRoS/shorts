/*
  license GPL v3 ...........

  description of this file:
  a page for viewing a user selected RSS feed ;

*/

import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

Popover {
    id: readingOptionsPopover

    Component.onCompleted: {
        fontSizeSlider.value = optionsKeeper.fontSize
    }

    Rectangle {
        anchors.fill: contentColumn
        color: "white"
        border.color: "#21b8e9"
    }

    Column {
        id: contentColumn

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        ListItem.Empty {
            Row {
                id: buttonRow

                property bool useDark: false
                spacing: units.gu(2)
                anchors.centerIn: parent
                Button {
                    text: i18n.tr("Dark")
                    width: units.gu(14)
                    color: UbuntuColors.coolGrey
                    onClicked: optionsKeeper.useDarkTheme = true
                }

                Button {
                    text: i18n.tr("Light")
                    width: units.gu(14)
                    color: "#21b8e9"
                    onClicked: optionsKeeper.useDarkTheme = false
                }
            }
        }

        ListItem.Empty {
            showDivider: false
            Label {
                id: lblLess

                text: "A"
                fontSize: "small"
                color: "black"
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
            }

            Slider {
                id: fontSizeSlider

                anchors {
                    right: lblMore.left
                    rightMargin: units.gu(1)
                    left: lblLess.right
                    leftMargin: units.gu(1)
                    verticalCenter: parent.verticalCenter
                }

                minimumValue: 0
                maximumValue: 2

                onValueChanged: {
                    var res
                    if (value < maximumValue / 3)
                        res = 0
                    else if (value < maximumValue / 3 * 2)
                        res = 1
                    else res = 2

                    optionsKeeper.fontSize = res
                }

                function formatValue(v) {
                    if (v < maximumValue / 3)
                        return i18n.tr("Small")
                    else if (v < maximumValue / 3 * 2)
                        return i18n.tr("Normal")
                    else return i18n.tr("Large")
                }
            } // SLider

            Label {
                id: lblMore

                text: "A"
                fontSize: "large"
                color: "black"
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
            }
        } // ListItem.Empty
    }
}
