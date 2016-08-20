file(GLOB NONGOOGLE_QML_JS_FILES *.qml *.js)

# make the files visible in the qtcreator tree
add_custom_target(ubuntu-rssreader-app_nongoogle_QMlFiles ALL SOURCES ${NONGOOGLE_QML_JS_FILES})

install(FILES ${NONGOOGLE_QML_JS_FILES} DESTINATION ${SHORTS_DIR}/nongoogle/)