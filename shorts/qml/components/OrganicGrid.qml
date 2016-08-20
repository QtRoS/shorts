import QtQuick 2.4
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3

Item {
    id: organicGridRoot

    anchors.fill: parent
    clip: true

    // comment organicGridRoot_0 start
    // below property and slot are used for expanding app window in desktop mode
    property bool canReload: false

    // How many items should we add - many at initial load and one on scrolling.
    property int amountToAdd: 0

    // connect to MainView's sizeChanged signal
    Connections{
        id: connMainview
        target: mainView

        onWidthChanged: sizeChangedHandler()
        onHeightChanged: sizeChangedHandler()
    }

    function sizeChangedHandler() {
        if (canReload) {
            canReload = false
            clear()
            reload()
        }
    }

    // comment organicGridRoot_0 end

    property var rectangleList: []
    property var articleModel: gridViewModel

    property bool allowOneImgA: true
    property int prevDelegateIndex: 0
    property int currentLoadedIndex: 0

    Component.onCompleted: {
        prepareComponents()
        canReload = true
    }

    property var delegateComponents: []

    function prepareComponents() {
        var componentsPath = "../delegates/" + "Article"
        var alignNames = ["TextA", "TextB", "OneImgA", "FullImg"]
        for (var i = 0; i < alignNames.length; i++) {
            var componentName = componentsPath + alignNames[i] + ".qml"
            delegateComponents[i] = Qt.createComponent(componentName)
            if (delegateComponents[i].status == Component.Error)
                console.log("prepareComponents", delegateComponents[i].errorString())
        }
    }

    /*!
      * \brief check collision of two article items
      * To team: little bit faster and much more readable.
      */
    function checkCollision(rect1, rect2) {
        return (rect1.y  <= rect2.y + rect2.height) &&
                (rect2.y <= rect1.y + rect1.height) &&
                (rect1.x <= rect2.x + rect2.width) &&
                (rect2.x <= rect1.x + rect1.width)
    }

    /*!
      * Adds a given article to the model. Also adds metadata about the
      * model to the article.
      */
    function addArticleToModel(article) {
        article.model = articleModel
        article.modelIndex = articleModel.count
        articleModel.append(article)
    }

    /*!
      * Clears all articles from the model and the view.
      */
    function clear() {
        var len = rectangleList.length
        for(var i = 0; i < len; i++) {
            rectangleList[i].visible = false
            rectangleList[i].destroy()
        }

        incubatedObjectCount = 0
        __itemsIncubated = 0
        rectangleList = []
        itemsPlacer.clear()
        organicFlickable.clear()
    }

    property int __itemsIncubated: 0
    function cleanUpIfNeeded() {
        if (++__itemsIncubated > 16) {
            __itemsIncubated = 0
            itemsPlacer.clearTemporaries()
            //console.log("cleanUpIfNeeded", "CleanUp")
        }
    }

    function addMoreIfNeeded() {
        if (--amountToAdd > 0)
            loadMoreItems()
    }

    function loadMoreItems() {
        if (!articleModel) {
            console.log("Whoops, null model in loadMoreItems")
            return
        }

        var amountToGo = articleModel.count - currentLoadedIndex
        if (amountToGo <= 0)
            return

        //console.time("loadmore")

        var i = currentLoadedIndex++
        var article = articleModel.get(i);
        var hasImage = article.image ? 0x2 : 0x0
        var useAlternateDelegate = (Math.random() > 0.5) ? 0x1 : 0

        var alignIndex = hasImage | useAlternateDelegate
        if (alignIndex == 2 && prevDelegateIndex == 2) {
            alignIndex = 3
        }
        prevDelegateIndex = alignIndex

        var component = delegateComponents[alignIndex]

        var properties = {
            "modelItem": article,
            "rssModel": articleModel,
            "modelIndex": i
        }

        //.console.log("INCUBATOR", article.id, "REQ")
        ++incubatedObjectCount
        var articleItemIncubator = component.incubateObject(organicFlickable.contentItem, properties)
        articleItemIncubator.onStatusChanged = function(status) {
            if (status === Component.Ready || status === Component.Error) {
                //.console.log("INCUBATOR", article.id, "FINISHED")
                --incubatedObjectCount
            } else {
                console.log("INCUBATOR", article.id, "LOADING")
            }

            if (status === Component.Ready) {
                itemsPlacer.placeObject(articleItemIncubator.object)
                addToListWithSort(articleItemIncubator.object)
                cleanUpIfNeeded()
                addMoreIfNeeded()
            }
        }
        //console.timeEnd("loadmore")
    }

    property int incubatedObjectCount: 0
    //onIncubatedObjectCountChanged: console.log("IncubatedCount is: ", incubatedObjectCount)

    function addToListWithSort(articleItem) {
        rectangleList.push(articleItem) // Later reference "articleItem" reused, keep in mind.
        for (var i = rectangleList.length - 1; i > 0 && rectangleList[i].x < rectangleList[i - 1].x; i--) {
            articleItem = rectangleList[i]
            rectangleList[i] = rectangleList[i - 1]
            rectangleList[i - 1] = articleItem
        }
    }

    /*!
      * Reloads the organic view. See inline comments for details.
      */
    function reload() {
        currentLoadedIndex = 0
        organicFlickable.scrollToStart()
        loadMore(16)
        canReload = true
    }

    /*!
      * dynamic loads others articles in organic view.
      */
    function loadMore (numToLoad) {
        amountToAdd = numToLoad || 1
        loadMoreItems()
    }

    /*!
      * Use Flickable as articles container
      */
    Flickable {
        id: organicFlickable
        anchors.fill: parent
        contentWidth: contentItem.childrenRect.width + units.gu(4)
        contentHeight: parent.height

        function clear() {
            cellNumber = 0
            leftIndex = 0
            rightIndex = 0
        }

        property real prevContentX: contentX
        property int cellNumber: 0
        property int leftIndex: 0
        property int rightIndex: 0
        readonly property double criticalX: 1 - visibleArea.widthRatio * 1.8 // Value 1.8 is leading to better visual effect in new algorithm.

        onContentXChanged: {
            if ((visibleArea.xPosition > criticalX) && incubatedObjectCount < 16 ) {
                //console.log("onContentXChanged", "loadMore", incubatedObjectCount)
                loadMore(4)
            }

            /* Dynamicly change item's visibility
             * only if "contentX" changed more than units.gu(4).
             */
            var cx = contentX
            var cell = Math.max(Math.floor(cx / units.gu(4)), 0)
            if (cell != cellNumber) {
                cellNumber = cell

                var rightBorder = cx + width
                var itm
                //console.log("INDEXES", leftIndex, rightIndex)
                //console.time("setItemsVisibility")
                if (prevContentX - cx > 0) { // Moving left
                    for (var i = Math.min(rightIndex, rectangleList.length - 1); i > 0; i--) {
                        itm = rectangleList[i]
                        //console.log("itm.x", itm.x, itm.secretProp, cx)
                        if (itm.x > rightBorder) {
                            itm.visible = false
                            rightIndex = i
                        } else {
                            itm.visible = true
                        }

                        if (itm.x < Math.max(cx - units.gu(24), 0)) {
                            do {
                                leftIndex = i;
                                rectangleList[i].visible = true
                            } while (i > 0 && itm.x === rectangleList[--i].x) // change visible of all items with the same "x" to true.
                            // console.log("left index changed to", leftIndex)
                            break
                        }
                    }
                } else { // Moving right
                    rightIndex = rectangleList.length - 1 // Helps in situation when no items out of the screen and rightIndex is not initialized.
                    var wasInit = false
                    for (var i = leftIndex; i < rectangleList.length; i++) {
                        itm = rectangleList[i]
                        //console.log("itm.x", itm.x, itm.secretProp, cx)
                        if (itm.x < Math.max(cx - units.gu(24), 0)) {
                            itm.visible = false
                        } else {
                            if (!wasInit) {
                                wasInit = true
                                leftIndex = i
                            }
                            itm.visible = true
                        }

                        if (itm.x > rightBorder) {
                            rightIndex = i
                            // console.log("right index changed to", rightIndex)
                            break
                        }
                    }
                }
                //console.timeEnd("setItemsVisibility")
            } // if (cell != cellNumber)

            prevContentX = cx
        }

        function scrollToStart() {
            contentX = 0
        }
    }

    QtObject {
        id: itemsPlacer

        // **********************************************************************
        property var chains: []
        property int globalChainIndex: 0
        // Later will be useful for debug.
        // property var globalColors: ["red", "blue", "magenta", "yellow", "green", "grey", "cyan", "white", "black", "brown", "aqua", "red", "blue", "magenta", "yellow", "green", "grey", "cyan", "white", "black", "brown", "aqua", "red", "blue", "magenta", "yellow", "green", "grey", "cyan", "white", "black", "brown", "aqua", "red", "blue", "magenta", "yellow", "green", "grey", "cyan", "white", "black", "brown", "aqua", "red", "blue", "magenta", "yellow", "green", "grey"]

        property int __lookBackCount: 3

        function clear() {
            chains = []
            globalChainIndex = 0
        }

        function clearTemporaries() {

            // TODO Maybe mark all chains as idle before last idle.

            var count = 0
            for (var i = 0; i < chains.length; i++) {
                if (chains[i].isIdle)
                    count++
                else break
            }

            /* Should remove garbage chains.
             */
            if (count > __lookBackCount) {
                chains.splice(0, count - __lookBackCount)
            }
        }

        function placeObject(obj) {
            var allChains = chains
            var isFound = false

            for (var i = 0; i < allChains.length; i++ ) {
                var chain = allChains[i]
                if (chain.isIdle)
                    continue

                if (chain.freeSpace > obj.height + units.gu(2)) {
                    var chainIndex = i

                    appendToChain(chainIndex, obj)
                    findObjX(chainIndex, obj)
                    var res = obj.x

                    // ***** Break chain **** //
                    if (getRight(chain.list.next.data) - res < obj.width / 3 ) {
                        //console.log("BREAK CHAIN - RIGHT")
                        chain.list = chain.list.next
                        chain.isIdle = true
                        /*var*/ chainIndex = allChains.length
                        /*var*/ chain = createNewChain()
                        appendToChain(chainIndex, obj)
                        findObjX(chainIndex, obj)
                    } else if ( getRight(obj) - chain.list.next.data.x  < obj.width / 3) {
                        //console.log("BREAK CHAIN - LEFT")
                        chain.list = chain.list.next // Remove from current
                        chain.freeSpace += obj.height + units.gu(2)

                        var prevChain = allChains[chainIndex - 1]
                        var lastObjInPrev = prevChain.list
                        var newNode = { "data" : obj, "next" : lastObjInPrev.next}
                        lastObjInPrev.next = newNode
                        prevChain.list = lastObjInPrev

                        // obj.color = itemsPlacer.globalColors[prevChain.globalIndex]

                        /* Previous chain must have more or equal freeSpace.
                         */
                        var hgtDiff = getBottom(obj) - getBottom(lastObjInPrev)
                        if (hgtDiff > 0)
                            prevChain.freeSpace -= hgtDiff

                    }
                    // ***** Break chain **** /

                    isFound = true
                    break
                }
            }

            /* Create new chain.
             */
            if (!isFound) {
                var chainIndex = allChains.length
                var chain = createNewChain()
                appendToChain(chainIndex, obj)
                findObjX(chainIndex, obj)
            }
        }

        function createNewChain() {
            var chain = {
                "freeSpace" : organicGridRoot.height,
                "list" : null,
                "isIdle" : false,
                "globalIndex" : globalChainIndex++
            }
            chains.push(chain)
            return chain
        }

        function appendToChain(chainIndex, obj) {
            var chain = chains[chainIndex]
            // obj.color = itemsPlacer.globalColors[chain.globalIndex]
            var newNode = { "data" : obj, "next" : chain.list}
            chain.list = newNode
            obj.y = organicGridRoot.height - chain.freeSpace + units.gu(2)
            chain.freeSpace -= obj.height + units.gu(2)

            /* If freeSpace now too small, chain become idle.
             * It means that it can't contain more items.
             */
            if (chain.freeSpace < units.gu(15) + units.gu(2)) {
                chain.isIdle = true
            }

            /* Important fix - previous chain must always have less freeSpace.
             */
            if (chainIndex > 0) {
                var prevChain = chains[chainIndex - 1]
                if (prevChain.freeSpace > chain.freeSpace) {
                    // console.log("PREV CHAIN HAVE MORE SPACE")
                    prevChain.freeSpace = chain.freeSpace
                    prevChain.isIdle = chain.isIdle // ? TODO THINK
                }
            }
        }

        function findObjX(chainIndex, obj) {
            var chain = chains[chainIndex]

            if (chain.globalIndex == 0) {
                obj.x = units.gu(2)
                return
            }

            var max = -1
            var allChaings = chains
            var startIndex = Math.max(0, chainIndex - __lookBackCount)
            for (var i = startIndex; i < chainIndex; i++) {
                var itChain = allChaings[i]
                var en = itChain.list

                while (en != null) {
                    if (isIntersectVert(en.data, obj)) {
                        var r = getRight(en.data)
                        if (r > max)
                            max = r
                    }

                    en = en.next
                }
            }

            if (max == -1) {
                max = chain.list.next.data.x
                //console.log("MAX IS", max)
                console.log(startIndex, chainIndex, allChaings)
            }

            obj.x = max + units.gu(2)
        }

        /* Returns true if two rectangles are intersect vertically.
         */
        function isIntersectVert(r1, r2) {
            return (r1.y < r2.y + r2.height && r2.y < r1.y + r1.height)
        }

        /* Returns right border of item.
         */
        function getRight(obj) {
            return obj.x + obj.width
        }

        /* Returns bottom border of item.
         */
        function getBottom(obj) {
            return obj.y + obj.height
        }
        // **********************************************************************
    } // QtObject
}
