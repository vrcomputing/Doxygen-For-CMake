
cmake_minimum_required(VERSION 3.27)

project(DoxygenForCMake VERSION 0.1.0)

option(DOXYGEN_CMAKE_GROUPING "If enabled group CMake entities e.g. options, functions, ..." ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(doxygen_cmake)

# we only include those so CMake validates them
include(example_functions)
include(example_macros)
include(example_options)
include(example_set)

include(customization)

find_package(Doxygen REQUIRED)

add_executable(example main.cpp)

# doxygen
set(DOXYGEN_PROJECT_NAME "Doxygen For CMake")
set(DOXYGEN_RECURSIVE YES)
set(DOXYGEN_WARNING YES)
set(DOXYGEN_WARN_IF_UNDOCUMENTED YES)
set(DOXYGEN_WARN_AS_ERROR FAIL_ON_WARNINGS_PRINT)
# VS Log Message Format: https://learn.microsoft.com/en-us/cpp/build/formatting-the-output-of-a-custom-build-step-or-build-event?view=msvc-170&redirectedfrom=MSDN
set(DOXYGEN_WARN_FORMAT [[$file ($line,0): $text]])
set(DOXYGEN_WARN_NO_PARAMDOC YES)
set(DOXYGEN_WARN_IF_UNDOC_ENUM_VAL YES)
set(DOXYGEN_WARN_IF_INCOMPLETE_DOC YES)
set(DOXYGEN_WARN_IF_DOC_ERROR YES)
set(DOXYGEN_ALWAYS_DETAILED_SEC YES) # create links to e.g. functions
set(DOXYGEN_GENERATE_TODOLIST YES)

set(DOXYGEN_EXTRACT_ALL NO) # !!!
set(DOXYGEN_EXTRACT_PRIVATE YES)
set(DOXYGEN_EXTRACT_PACKAGE YES)
set(DOXYGEN_EXTRACT_STATIC YES)
set(DOXYGEN_EXTRACT_ANON_NSPACES YES)
set(DOXYGEN_EXTRACT_LOCAL_METHODS YES)
set(EXTRACT_LOCAL_CLASSES YES)

set(DOXYGEN_FULL_PATH_NAMES YES)
set(DOXYGEN_STRIP_FROM_PATH ${CMAKE_CURRENT_BINARY_DIR}/doxygen/generated)

set(DOXYGEN_FILE_PATTERNS
    [[*.h]]
    [[*.hpp]]
    [[*.c]]
    [[*.cpp]]
    [[CMakeLists.txt]]
    [[*.cmake]]
    [[*.dox]]
)

set(DOXYGEN_ALIASES
    [["getter{1}=@brief Getter for @ref \1^^@returns Returns the value of property @ref \1"]]
    [["setter=@brief Setter for @ref "]]
    [["signal=@brief Signal for @ref "]]
    [["ownercaller=@warning Return value owner is caller!"]]
    [["ownercallee=@warning Return value owner is callee!"]]
)

set(DOXYGEN_EXTENSION_MAPPING
    [[txt=Python]]
    [[cmake=Python]]
)

set(DOXYGEN_GENERATED_INPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doxygen/generated)

# generate a list of doxygen groups to put the cmake entities in
if(DOXYGEN_CMAKE_GROUPING)
    set(DOXYGEN_CMAKE_GROUPS_FILE ${DOXYGEN_GENERATED_INPUT_DIR}/doxygen_groups.dox)
    custom_groups_file(${DOXYGEN_CMAKE_GROUPS_FILE})
    list(APPEND CMAKE_DOXYGEN_INPUT ${DOXYGEN_CMAKE_GROUPS_FILE})
endif()

list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/doxygen_cmake.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_functions.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_macros.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_options.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_set.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_FILE})
if(DOXYGEN_CMAKE_GROUPING)
    list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/customization.cmake)
endif()

# generate doxygen for all cmake files
foreach(FILENAME IN LISTS CMAKE_FILES_FOR_DOXYGEN)
    string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR} ${DOXYGEN_GENERATED_INPUT_DIR} FILENAME_OUT ${FILENAME})
    doxygen_generate_cmake(
        ${FILENAME} ${FILENAME_OUT}
        # declare pattern for callback
        "CMAKE_EMPTY,CMAKE_COMMENT,CMAKE_FUNCTION,CMAKE_MACRO,CMAKE_OPTION,CMAKE_SET"
        # <mv-keyword> <pattern>                           <callback>               <args>
        CMAKE_COMMENT  "^##.*$"                            custom_comment_callback  CUSTOM
        CMAKE_FUNCTION "^[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]" custom_function_callback
        CMAKE_MACRO    "^[Mm][Aa][Cc][Rr][Oo]"             custom_macro_callback
        CMAKE_OPTION   "^[Oo][Pp][Tt][Ii][Oo][Nn]"         custom_option_callback
        CMAKE_SET      "^[Ss][Ee][Tt] *\\(.*"              custom_set_callback
    )
    list(APPEND CMAKE_DOXYGEN_INPUT ${FILENAME_OUT})
endforeach()

# generate the final doxygen documentation
doxygen_add_docs(
    doxygen
    ALL
    ${CMAKE_CURRENT_LIST_DIR}/main.cpp
    ${CMAKE_DOXYGEN_INPUT}
    COMMENT "Generate doxygen"
)

set(CPACK_GENERATOR "ZIP")
set(CPACK_PACKAGE_NAME "doxygen-for-cmake")
set(CPACK_PACKAGE_VERSION "${CMAKE_PROJECT_VERSION}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
include(CPack)

install(FILES ${CMAKE_CURRENT_LIST_DIR}/cmake/doxygen_cmake.cmake DESTINATION cmake)
install(DIRECTORY ${CMAKE_BINARY_DIR}/html DESTINATION doc)