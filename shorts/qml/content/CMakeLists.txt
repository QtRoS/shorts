file(GLOB CONTENT_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_content_QMlFiles ALL SOURCES ${CONTENT_QML_JS_FILES})

install(FILES ${CONTENT_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/content/)