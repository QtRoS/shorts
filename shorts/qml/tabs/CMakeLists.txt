file(GLOB TABS_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_tabs_QMlFiles ALL SOURCES ${TABS_QML_JS_FILES})

install(FILES ${TABS_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/tabs/)