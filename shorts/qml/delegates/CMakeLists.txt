file(GLOB DELEGATES_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_delegates_QMlFiles ALL SOURCES ${DELEGATES_QML_JS_FILES})

install(FILES ${DELEGATES_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/delegates/)