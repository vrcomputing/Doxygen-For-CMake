
cmake_minimum_required(VERSION 3.27)

project(DoxygenForCMake VERSION 0.1.0)

option(DOXYGEN_CMAKE_GROUPING "Group CMake entities e.g. options, functions, ..." ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

include(doxygen_cmake)
include(example_functions)
include(example_macros)
include(example_options)
include(example_set)

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
file(WRITE ${DOXYGEN_CMAKE_GROUPS_FILE}
[[
/// @defgroup cmake_function CMake Functions
/// @{
/// @}
///
/// @defgroup cmake_macro CMake Macros
/// @{
/// @}
///
/// @defgroup cmake_option CMake Options
/// @{
/// @}
///
/// @defgroup cmake_variable CMake Variables
/// @{
/// @}
///
/// @defgroup cmake_cache_variable CMake Cache Variables
/// @{
/// @}
]])

# list of individual files as input for doxygen
list(APPEND CMAKE_DOXYGEN_INPUT ${DOXYGEN_CMAKE_GROUPS_FILE})

endif()


list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_functions.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_macros.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_options.cmake)
list(APPEND CMAKE_FILES_FOR_DOXYGEN ${CMAKE_CURRENT_LIST_DIR}/cmake/example_set.cmake)

function(custom_option_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)
        file(APPEND ${OUTPUT_FILENAME} "##\n")
        file(APPEND ${OUTPUT_FILENAME} "## @details\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ingroup cmake_option\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ref cmake_option \"\"\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    doxygen_option_callback(${ARGV})
endfunction()

function(custom_function_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)
        file(APPEND ${OUTPUT_FILENAME} "##\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ingroup cmake_function\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ref cmake_function\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    doxygen_function_callback(${ARGV})
endfunction()

function(custom_macro_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)
        file(APPEND ${OUTPUT_FILENAME} "##\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ingroup cmake_macro\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ref cmake_macro\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    doxygen_macro_callback(${ARGV})
endfunction()

function(custom_set_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)

        math(EXPR LINE_INDEX "${INPUT_LINE_INDEX}-1")
        doxygen_get_line(${INPUT_FILENAME} ${LINE_INDEX} PREVIOUS_LINE)
        if(PREVIOUS_LINE MATCHES "^ *##")
            doxygen_tokenize(${INPUT_LINE} TOKENS)
            cmake_parse_arguments(CCC "PARENT_SCOPE;FORCE" "" "CACHE" ${TOKENS})
            set(DOXYGEN_CMAKE_GROUP "cmake_variable")
            if(CCC_CACHE)
                set(DOXYGEN_CMAKE_GROUP "cmake_cache_variable")
            endif()
            file(APPEND ${OUTPUT_FILENAME} "##\n")
            file(APPEND ${OUTPUT_FILENAME} "## @ingroup ${DOXYGEN_CMAKE_GROUP}\n")
            file(APPEND ${OUTPUT_FILENAME} "##\n")
            file(APPEND ${OUTPUT_FILENAME} "## @ref ${DOXYGEN_CMAKE_GROUP} \"\"\n")
            file(APPEND ${OUTPUT_FILENAME} "##\n")
            if(CCC_FORCE)
                file(APPEND ${OUTPUT_FILENAME} "## @remark  @c [FORCE]\n")
            endif()
        endif()
    endif()

    doxygen_set_callback(${ARGV})
endfunction()

## @brief Custom callback for a line that matched the comment pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details ARGV holds all arguments to the function where as ARGN holds the list
## of arguments past the last expected argument
##
## ARGV = {OUTPUT_FILENAME, INPUT_FILENAME, INPUT_LINE_INDEX, INPUT_LINE, ...}
## ARGN = {...}
##
## @see https://cmake.org/cmake/help/latest/command/function.html#arguments
function(custom_comment_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "${INPUT_LINE}\n")
    cmake_parse_arguments(CCC "CUSTOM" "" "" ${ARGN})
    if(CCC_CUSTOM)
        message(DEBUG "CUSTOM received")
    endif()
endfunction()

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