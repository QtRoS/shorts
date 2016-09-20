TEMPLATE = app
TARGET = shorts

load(ubuntu-click)

QT += qml quick

SOURCES += main.cpp \
    CachingNetworkManagerFactory.cpp \
    xml2json/utilities.cpp \
    networkmanager.cpp

RESOURCES += shorts.qrc

OTHER_FILES += ..\shorts.apparmor \
    ..\shorts.desktop \
    ..\shorts.png \
    ..\contenthub.json \
    qml/utils/databasemodule_v2.js \
    qml/utils/dateutils.js \
    qml/utils/imgSeparator.js \
    qml/components/ArticleViewItem.qml \
    qml/pages/TopicManagementPage.qml \
    qml/pages/SettingsPage.qml \
    qml/components/GoogleFeedApi.qml \
    qml/components/GridModeItem.qml \
    qml/components/ListModeItem.qml \
    qml/components/NetworkManager.qml \
    qml/components/OptionsKeeper.qml \
    qml/components/OrganicGrid.qml \
    qml/components/PageLoader.qml \
    qml/components/ReadingOptions.qml \
    qml/components/DarkModeShader.qml \
    qml/delegates/ArticleFullImg.qml \
    qml/delegates/ArticleOneImgA.qml \
    qml/delegates/ArticleTextA.qml \
    qml/delegates/ArticleTextB.qml \
    qml/pages/AppendFeedPage.qml \
    qml/pages/ArticleViewPage.qml \
    qml/pages/ChooseTopicPage.qml \
    qml/pages/CreateTopicPage.qml \
    qml/pages/EditFeedPage.qml \
    qml/pages/FeedComponent.qml \
    qml/pages/SwipeDelete.qml \
    qml/pages/YadLoginPage.qml \
    qml/pages/TopicComponent.qml \
    qml/tabs/BaseTab.qml \
    qml/tabs/SavedTab.qml \
    qml/tabs/ShortsTab.qml \
    qml/tabs/TopicTab.qml \
    qml/shorts-app.qml \
    qml/content/SharePage.qml \
    qml/content/YadApi.qml \
    qml/nongoogle/AppendNGFeedPage.qml \
    qml/nongoogle/Positioner.qml \
    qml/nongoogle/XmlNetwork.qml \
    qml/pages/MainPage.qml \
    qml/components/ActionIcon.qml

#specify where the config files are installed to
config_files.path = /.
config_files.files += $${OTHER_FILES}
message($$config_files.files)
INSTALLS+=config_files

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

HEADERS += \
    CachingNetworkManagerFactory.h \
    xml2json/utilities.h \
    xml2json/rapidjson/error/en.h \
    xml2json/rapidjson/error/error.h \
    xml2json/rapidjson/internal/biginteger.h \
    xml2json/rapidjson/internal/diyfp.h \
    xml2json/rapidjson/internal/dtoa.h \
    xml2json/rapidjson/internal/ieee754.h \
    xml2json/rapidjson/internal/itoa.h \
    xml2json/rapidjson/internal/meta.h \
    xml2json/rapidjson/internal/pow10.h \
    xml2json/rapidjson/internal/stack.h \
    xml2json/rapidjson/internal/strfunc.h \
    xml2json/rapidjson/internal/strtod.h \
    xml2json/rapidjson/msinttypes/inttypes.h \
    xml2json/rapidjson/msinttypes/stdint.h \
    xml2json/rapidjson/allocators.h \
    xml2json/rapidjson/document.h \
    xml2json/rapidjson/encodedstream.h \
    xml2json/rapidjson/encodings.h \
    xml2json/rapidjson/filereadstream.h \
    xml2json/rapidjson/filestream.h \
    xml2json/rapidjson/filewritestream.h \
    xml2json/rapidjson/memorybuffer.h \
    xml2json/rapidjson/memorystream.h \
    xml2json/rapidjson/prettywriter.h \
    xml2json/rapidjson/rapidjson.h \
    xml2json/rapidjson/reader.h \
    xml2json/rapidjson/stringbuffer.h \
    xml2json/rapidjson/writer.h \
    xml2json/rapidxml/rapidxml.hpp \
    xml2json/rapidxml/rapidxml_iterators.hpp \
    xml2json/rapidxml/rapidxml_print.hpp \
    xml2json/rapidxml/rapidxml_utils.hpp \
    xml2json/xml2json.hpp \
    networkmanager.h

DISTFILES += \
    qml/content/YadSyncHelper.qml \
    qml/components/PageLoader.qml
