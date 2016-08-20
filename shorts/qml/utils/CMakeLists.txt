file(GLOB UTILS_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_utils_QMlFiles ALL SOURCES ${UTILS_QML_JS_FILES})

install(FILES ${UTILS_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/utils/)