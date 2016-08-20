import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: abstractButton

    property alias icon: _icon

    width: units.gu(4)
    height: width

    Rectangle {
        visible: abstractButton.pressed
        anchors.fill: parent
        color: "#4ec6ee"
    }

    Icon {
        id: _icon
        width: units.gu(2)
        height: width
        anchors.centerIn: parent
        color: "#5d5d5d"
    }
}
