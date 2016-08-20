import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
    id: root

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Sharing")
    }

    property var activeTransfer
    property string articleUrl

//    Component.onCompleted: {
//        console.log("ContentTransfer.Created", ContentTransfer.Created)
//        console.log("ContentTransfer.Initiated", ContentTransfer.Initiated)
//        console.log("ContentTransfer.InProgress", ContentTransfer.InProgress)
//        console.log("ContentTransfer.Downloading", ContentTransfer.Downloading)
//        console.log("ContentTransfer.Downloaded", ContentTransfer.Downloaded)
//        console.log("ContentTransfer.Charged", ContentTransfer.Charged)
//        console.log("ContentTransfer.Collected", ContentTransfer.Collected)
//        console.log("ContentTransfer.Aborted", ContentTransfer.Aborted)
//        console.log("ContentTransfer.Created", ContentTransfer.Created)
//        console.log("ContentTransfer.Finalized", ContentTransfer.Finalized)
//    }

    Component {
        id: resultComponent
        ContentItem { }
    }

    function __exportItemsWhenPossible(url) {
        console.log("__exportItemsWhenPossible", root.activeTransfer.state, url)
        if (root.activeTransfer.state === ContentTransfer.InProgress) {
            root.activeTransfer.items = [ resultComponent.createObject(root, {"url": url}) ]
            root.activeTransfer.state = ContentTransfer.Charged
        }
    }

    ContentPeerPicker {
        id: peerPicker
        showTitle: true

        // Type of handler: Source, Destination, or Share
        handler: ContentHandler.Share
        contentType: ContentType.Links

        onPeerSelected: {
            root.activeTransfer = peer.request()
            root.__exportItemsWhenPossible(root.articleUrl)
            pageStack.pop(root)
        }

        onCancelPressed: {
            pageStack.pop(root)
        }
    }

    Connections {
        target: root.activeTransfer ? root.activeTransfer : null
        onStateChanged: {
            console.log("curTransfer StateChanged: " + root.activeTransfer.state);
            __exportItemsWhenPossible(root.articleUrl)
        }
    }
}
