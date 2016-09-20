import QtQuick 2.4

Loader {
    id: pageLoader

    active: false

    function doAction(action) {
        if (!active)
            active = true
        if (status == Loader.Ready)
            action(item)
        else __deferredAction = action
    }

    property var __deferredAction: null

    onStatusChanged: {
        console.log("PageLoader status changed", status)
        if (status == Loader.Ready && __deferredAction)
        {
            __deferredAction(item)
            __deferredAction = null
        } else if (status == Loader.Error)
            console.log("PageLoader error")
    }
}
