import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: abstractButton

    property alias icon: _icon
    property alias text: _text

    height: units.gu(3)
    width: contentRow.width

    Rectangle {
        visible: abstractButton.pressed
        anchors.fill: parent
        color: "lightgrey"
    }

    Row {
        id: contentRow

        spacing: units.gu(0.5)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: _text
            anchors.verticalCenter: parent.verticalCenter
        }

        Icon {
            id: _icon
            width: units.gu(3)
            height: width
            anchors.verticalCenter: parent.verticalCenter
            color: "#EB6536"
        }
    }
}
