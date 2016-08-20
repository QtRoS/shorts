# Searches for all qml and javascript files in the current directory
# to add them to the project, if you add new files in the directory
# rerun cmake to make sure they show up in the project tree
file(GLOB QML_JS_FILES *.qml *.js)

# Make the files visible in qtcreator
add_custom_target(root_QMlFiles ALL SOURCES ${QML_JS_FILES})

# Substitute variables in the desktop file
# configure_file(${DESKTOP_FILE_NAME}.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME}.in)
# 
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME} DESTINATION ${DESKTOP_DIR})
install(FILES ${QML_JS_FILES} DESTINATION ${SHORTS_DIR})

add_subdirectory(components)
add_subdirectory(content)
add_subdirectory(delegates)
add_subdirectory(icons)
add_subdirectory(pages)
add_subdirectory(tabs)
add_subdirectory(utils)
add_subdirectory(nongoogle)
