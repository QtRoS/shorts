.pragma library

function separate(content) {
    var result = []
    var rx = /<img.*?src="(.*?)"/g

    var e = rx.exec(content)
    while (e) {
        // Some simple checks here.
        if (e[1].indexOf("http") === 0)
            result.push(e[1])

        e = rx.exec(content)
    }

    return result
}

function getFirstImage(content) {
    var imgArr = separate(content)

    if (imgArr.length)
        return imgArr[0]

    return null
}

function grabArticleImage(e) {
    if (e.mediaGroups) {
        var medias = e.mediaGroups
        for (var i = 0; i < medias.length; i++) {
            var media = medias[i]

            for (var j = 0; j < media.contents.length; j++) {
                var cont = media.contents[j]

                if (cont.type === "image/jpeg" || cont.type === "image/png" ||
                        cont.type === "image/jpeg" || cont.type === "image/pjpeg" ||
                        cont.type === "image/svg+xml" || cont.medium === "image") {
                    return cont.url
                }
            }
        }
    }

    return getFirstImage(e.content)
}

function clearFromBadTags(content) {
    /* Remove non empty too. Useless anyway.
     */
    content = content.replace(/alt=".*?"/g, "")
    content = content.replace(/title=".*?"/g, "")
    return content
}
