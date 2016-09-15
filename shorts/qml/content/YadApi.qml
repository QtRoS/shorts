import QtQuick 2.4

QtObject {
    id: yadApi

    /*
        This signal emitted when result is received.
        # resObj
            @ task
                @ code
                @ doc
                @ id
            @ response
                !status
                !statusText
            !isError
        # code
     */
    signal responseReceived(var resObj, string code)

    property string clientId: "50a233945dff4787849304ab21ac42d7"
    property string clientPass: ""
    property string accessToken: ""

    readonly property bool requestLogEnabled: false

    function generateTokenRequestUrl() {
        return "https://oauth.yandex.ru/authorize?response_type=token&client_id=%1&display=popup".arg(clientId)
    }

    function generateLogoutUrl() {
        return "https://oauth.yandex.ru/logout?client_id=%1".arg(clientId)
    }

    function logout() {
        var baseUrl = "https://oauth.yandex.ru/logout?client_id=%1".arg(clientId)
        return __makeRequest(baseUrl, "logout")
    }

    function getMetaData(path, options) {
        path = path || "/"
        options = options || {}
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources?path=" + encodeURIComponent(path)

        if (options.sort)
            baseUrl += "&sort=" + options.sort

        if (options.limit)
            baseUrl += "&limit=" + options.limit
        else baseUrl += "&limit=" + 2048

        if (options.offset)
            baseUrl += "&offset=" + options.offset

        return __makeRequest(baseUrl, "metadata")
    }

    function copyTo(from, path, overwrite) {
        if (!from || !path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/copy?from=" + encodeURIComponent(from)
        baseUrl += "&path=" + encodeURIComponent(path)
        if (overwrite)
            baseUrl += "&overwrite=true"
        return __makeRequest(baseUrl, "copy", "POST")
    }

    function moveTo(from, path, overwrite) {
        if (!from || !path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/move?from=" + encodeURIComponent(from)
        baseUrl += "&path=" + encodeURIComponent(path)
        if (overwrite)
            baseUrl += "&overwrite=true"
        return __makeRequest(baseUrl, "move", "POST")
    }

    function remove(path, permanently) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources?path=" + encodeURIComponent(path)
        if (permanently)
            baseUrl += "&permanently=true"
        return __makeRequest(baseUrl, "remove", "DELETE")
    }

    function createFolder(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "create", "PUT")
    }

    function publish(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/publish?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "publish", "PUT")
    }

    function unpublish(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/unpublish?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "unpublish", "PUT")
    }

    function download(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/download?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "download")
    }

    function upload(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/resources/upload?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "upload")
    }

    function saveToDisk(public_key) {
        if (!public_key)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/public-resources/save-to-disk/?public_key=" + encodeURIComponent(public_key)
        return __makeRequest(baseUrl, "saveToDisk")
    }

    function diskInformation() {
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/"
        return __makeRequest(baseUrl, "diskInformation")
    }

    /* Trash */
    function trashGetMetadata(path, options) {
        path = path || "/"
        options = options || {}
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/trash/resources?path=" + encodeURIComponent(path)

        if (options.limit)
            baseUrl += "&limit=" + options.limit
        else baseUrl += "&limit=" + 2048

        if (options.offset)
            baseUrl += "&offset=" + options.offset

        return __makeRequest(baseUrl, "trashMetadata")
    }

    function trashRemove(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/trash/resources?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "trashRemove", "DELETE")
    }

    function trashRestore(path) {
        if (!path)
            return
        var baseUrl = "https://cloud-api.yandex.net/v1/disk/trash/resources/restore?path=" + encodeURIComponent(path)
        return __makeRequest(baseUrl, "trashRestore", "PUT")
    }

    /* Private */
    function __makeRequest(request, code, method) {
        method = method || "GET"

        if (requestLogEnabled)
            console.log("__makeRequest", request, code, method)

        var doc = new XMLHttpRequest()
        var task = {"code" : code, "doc" : doc, "id" : __requestIdCounter++,
            "setMeta" : function(key, meta) { this[key] = meta; return this; }}

        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {

                var resObj = { "task" : task}

                if (doc.status != 200 && doc.status != 201 && doc.status != 202 && doc.status != 204  ) {
                    resObj.isError = true
                    resObj.response = { "statusText" : doc.statusText, "status" : doc.status}
                } else {
                    var parsedResponse = {}
                    try {
                        parsedResponse = JSON.parse(__preProcessData(code, doc.responseText))
                    } catch (e) { }
                    if (parsedResponse.error) {
                        resObj.isError = true
                    }
                    resObj.response = parsedResponse
                }

                __emitSignal(resObj, code)
            }
        }

        doc.open(method, request, true)
        doc.setRequestHeader("Authorization", "OAuth " + accessToken)
        doc.send()

        return task
    }

    function __preProcessData(code, data) {
        return data
    }

    function __emitSignal(resObj, operationCode) {
        responseReceived(resObj, operationCode)
    }

    property int __requestIdCounter: 0
} // API
