import QtQuick 2.4

QtObject {
    id: rootObject

    property bool inProgress: __doc != null

    signal findResult(var result)
    signal loadResult(var result)

    property var __doc: null

    /* Load feed by URL.
     */
    function loadFeed(feedUrl, num) {
        abort(true)

        if (num)
            num = Math.min(num, 100)
        else num = 50

        __doc = new XMLHttpRequest()
        var doc = __doc

        doc.onreadystatechange = function() {

//            print("xmlnetwork onreadystatechange: ", doc.readyState, doc.status, feedUrl)
            if (doc.readyState === XMLHttpRequest.DONE) {

                var resObj
                if (doc.status == 200) {
                    resObj = utilities.xmlToJson(doc.responseText)
                } else { // Error
                    resObj = {"responseDetails" : doc.statusText,
                        "responseStatus" : doc.status}
                }

                __doc = null
                loadResult(resObj)
            }
        }

        doc.open("GET", feedUrl, true);
        doc.send();
    }

    /* Param "isAbortOnly" used to preserve
     * property "__doc" in not null state.
     * inProgress binded to it so we can avoid
     * additional recalculations.
     */
    function abort(isAbortOnly) {
        if (__doc != null) {
            __doc.abort()
            if (!isAbortOnly)
                __doc = null
        }
    }

    /* Return true if some kind of errors detected.
     */
    function checkForErrors(result) {
        if (result.responseStatus == 200 ||   // HTTP OK
                result.responseStatus == 0) { // ABORTED
            return false
        }

        return true
    }
} // QtObject
