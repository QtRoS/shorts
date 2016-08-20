import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

Item {
    id: gridPage

    property int topicId: 0
    property var gridViewModel: null

    function reload () {
        gridViewModel = getModel()
        organicGridView.reload()
    }

    function clear() {
        gridViewModel = null
        organicGridView.clear()
    }

    function triggerLoadMore() {
        organicGridView.loadMore()
    }

    OrganicGrid {
        id: organicGridView
    }
}
