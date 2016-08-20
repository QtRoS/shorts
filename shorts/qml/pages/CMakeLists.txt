file(GLOB PAGES_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_pages_QMlFiles ALL SOURCES ${PAGES_QML_JS_FILES})

install(FILES ${PAGES_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/pages/)