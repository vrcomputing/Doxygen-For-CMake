## @brief Generate the Doxygen groups for the CMake entities
##
## @param OUTPUT_FILENAME  The output file for the generated groups
##
## @details The following group are being generated
## - @ref cmake_function
## - @ref cmake_macro
## - @ref cmake_option
## - @ref cmake_variable
## - @ref cmake_cache_variable
function(custom_groups_file OUTPUT_FILENAME)
file(WRITE ${OUTPUT_FILENAME}
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
endfunction()

## @brief Custom callback for a line that matched the option pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Will group the option accordingly
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

## @brief Custom callback for a line that matched the function pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Will group the function accordingly
function(custom_function_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)
        file(APPEND ${OUTPUT_FILENAME} "##\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ingroup cmake_function\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ref cmake_function\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    doxygen_function_callback(${ARGV})
endfunction()

## @brief Custom callback for a line that matched the macro pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Will group the macro accordingly
function(custom_macro_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    if(DOXYGEN_CMAKE_GROUPING)
        file(APPEND ${OUTPUT_FILENAME} "##\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ingroup cmake_macro\n")
        file(APPEND ${OUTPUT_FILENAME} "## @ref cmake_macro\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    doxygen_macro_callback(${ARGV})
endfunction()

## @brief Custom callback for a line that matched the set pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Will group the variable or cache variable accordingly
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
