## @brief Tokenize @p INPUT and store the tokens into a variable called @p OUTPUT in caller's scope
## @param INPUT  Input text line
## @param OUTPUT Output variable name to put the tokens into in caller's scope
function(doxygen_tokenize INPUT OUTPUT)
    set(LINE ${INPUT})
    string(REGEX REPLACE [[^([^\(]*)(\()(.*)]] "\\1 \\3" LINE ${LINE})
    string(REGEX REPLACE [[\)$]] "" LINE ${LINE})
    string(REGEX MATCHALL [["[^"]+"|[^ ]+|\$\{[^\}]+\}]] TOKENS ${LINE})
    set(${OUTPUT} ${TOKENS} PARENT_SCOPE)
endfunction()

## @brief Get the line at index @p INPUT_LINE_INDEX from the file @p INPUT_FILENAME
## and stores it in the variable called @p OUTPUT_VARIABLE in the caller's scope
##
## @param INPUT_FILENAME The input filename
## @param INPUT_LINE_INDEX The input file's line index
## @param OUTPUT_VARIABLE The output variable name
function(doxygen_get_line INPUT_FILENAME INPUT_LINE_INDEX OUTPUT_VARIABLE)
    file(STRINGS ${INPUT_FILENAME} LINES)
    list(GET LINES ${INPUT_LINE_INDEX} LINE)
    list(LENGTH LINES LINES_COUNT)
    if(INPUT_LINE_INDEX GREATER_EQUAL 0 AND INPUT_LINE_INDEX LESS LINES_COUNT)
        set(${OUTPUT_VARIABLE} ${LINE} PARENT_SCOPE)
    else()
        unset(${OUTPUT_VARIABLE} PARENT_SCOPE)
    endif()
endfunction()

## @brief Append a header warning that the resulting file is indeed generated
##
## @param OUTPUT_FILENAME The output filename
## @param INPUT_FILENAME The input filename
function(doxygen_generate_file_header OUTPUT_FILENAME INPUT_FILENAME)
    get_filename_component(FILENAME ${INPUT_FILENAME} NAME)
    file(APPEND ${OUTPUT_FILENAME} "# THIS FILE IS GENERATED!\n\n")
    file(APPEND ${OUTPUT_FILENAME} "## @file ${FILENAME}\n\n")
endfunction()

## @brief Append a footer warning that the resulting file is indeed generated
##
## @param OUTPUT_FILENAME The output filename
## @param INPUT_FILENAME The input filename
function(doxygen_generate_file_footer OUTPUT_FILENAME INPUT_FILENAME)
    file(APPEND ${OUTPUT_FILENAME} "# THIS FILE IS GENERATED!\n\n")
endfunction()

## @brief Default callback for a line that matched the empty line pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Appends an empty line to the file @p OUTPUT_FILENAME
function(doxygen_empty_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "\n")
endfunction()

## @brief Default callback for a line that matched the comment pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Appends the line @p INPUT_LINE as is to the file @p OUTPUT_FILENAME
function(doxygen_comment_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "${INPUT_LINE}\n")
endfunction()

## @brief Default callback for a line that matched the function pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Parses the tokens from the line @p INPUT_LINE and append a Python function
## to the file @ OUTPUT_FILENAME
function(doxygen_function_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)
    list(JOIN TOKENS ", " METHOD_ARGS)
    file(APPEND ${OUTPUT_FILENAME} "def ${METHOD_NAME}(${METHOD_ARGS}):\n\tpass\n\n")
endfunction()

## @brief Default callback for a line that matched the macro pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Parses the tokens from the line @p INPUT_LINE and append a Python function
## to the file @ OUTPUT_FILENAME
function(doxygen_macro_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)
    list(JOIN TOKENS ", " METHOD_ARGS)
    file(APPEND ${OUTPUT_FILENAME} "def ${METHOD_NAME}(${METHOD_ARGS}):\n\tpass\n\n")
endfunction()

## @brief Default callback for a line that matched the option pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Parses the tokens from the line @p INPUT_LINE and append a Python variable
## to the file @ OUTPUT_FILENAME
function(doxygen_option_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)
    list(POP_FRONT TOKENS METHOD_DESC)
    list(POP_FRONT TOKENS METHOD_ARGS)

    # check if option has doxygen or cache help entry
    math(EXPR LINE_INDEX "${INPUT_LINE_INDEX}-1")
    doxygen_get_line(${INPUT_FILENAME} ${LINE_INDEX} PREVIOUS_LINE)
    if(PREVIOUS_LINE MATCHES "^ *##" OR METHOD_DESC)
        file(APPEND ${OUTPUT_FILENAME} "## ${METHOD_DESC}\n")
        file(APPEND ${OUTPUT_FILENAME} "##\n")
    endif()
    file(APPEND ${OUTPUT_FILENAME} "${METHOD_NAME} = ${METHOD_ARGS}\n\n")
endfunction()

## @brief Default callback for a line that matched the set pattern
##
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
##
## @details Parses the tokens from the line @p INPUT_LINE and append a Python variable
## to the file @ OUTPUT_FILENAME
function(doxygen_set_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)

    # check if option has doxygen or cache help entry
    math(EXPR LINE_INDEX "${INPUT_LINE_INDEX}-1")
    doxygen_get_line(${INPUT_FILENAME} ${LINE_INDEX} PREVIOUS_LINE)
    if(PREVIOUS_LINE MATCHES "^ *##")
        cmake_parse_arguments(DSC "PARENT_SCOPE;FORCE" "" "CACHE" ${TOKENS})
        if(DSC_CACHE)
            list(GET DSC_CACHE 0 VARIABLE_TYPE)
            list(GET DSC_CACHE 1 VARIABLE_DOCSTRING)
            file(APPEND ${OUTPUT_FILENAME} "## ${VARIABLE_DOCSTRING}\n")
            file(APPEND ${OUTPUT_FILENAME} "##\n")
            list(JOIN DSC_UNPARSED_ARGUMENTS ", " UNPARSED_ARGUMENTS)
            file(APPEND ${OUTPUT_FILENAME} "${METHOD_NAME} : ${VARIABLE_TYPE} = ${UNPARSED_ARGUMENTS}\n\n")
        else()
            list(JOIN DSC_UNPARSED_ARGUMENTS ", " UNPARSED_ARGUMENTS)
            file(APPEND ${OUTPUT_FILENAME} "${METHOD_NAME} = ${UNPARSED_ARGUMENTS}\n\n")
        endif()
    endif()
endfunction()

## @brief Generate doxygen (python) output file
##
## @param DOX_INPUT  The input filename
## @param DOX_OUTPUT The output filename
## @param MULTI_VALUE_KEYWORDS Custom multi-value keywords for registering patterns and
## associating callbacks with it
##
## @details This function parses the input file @p DOX_INPUT line by line and trys
## to match each line against a RegEx pattern. The associated callback is then called.
##
## @par Customization
## Custom callbacks can be registred by declaring them after the @p MULTI_VALUE_KEYWORDS.
## The @p MULTI_VALUE_KEYWORDS are being passed into cmake_parse_arguments to help parsing
## the custom callback decalration. A declaration comprises a keyword, a RegEx pattern, a callback
## and an optional list of additional callback arguments.
##
## @code{.py}
## doxygen_generate_cmake(
##     ${INPUT_FILENAME} ${OUTPUT_FILENAME}
##     # declare pattern for callback
##     "CMAKE_COMMENT,CMAKE_FUNCTION,CMAKE_MACRO,CMAKE_OPTION,CMAKE_SET"
##     # <mv-keyword> <pattern>                           <callback>               <args>
##     CMAKE_COMMENT  "^##.*$"                            custom_comment_callback  CUSTOM
##     CMAKE_FUNCTION "^[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]" custom_function_callback
##     CMAKE_MACRO    "^[Mm][Aa][Cc][Rr][Oo]"             custom_macro_callback
##     CMAKE_OPTION   "^[Oo][Pp][Tt][Ii][Oo][Nn]"         custom_option_callback
##     CMAKE_SET      "^[Ss][Ee][Tt] *\\(.*"              custom_set_callback
## )
## @endcode
##
## @attention @p MULTI_VALUE_KEYWORDS keyword must be a comma-separated string list e.g. @c "SET,FUNCTION"
function(doxygen_generate_cmake DOX_INPUT DOX_OUTPUT MULTI_VALUE_KEYWORDS)
    string(REPLACE "," ";" MULTI_VALUE_KEYWORDS "${MULTI_VALUE_KEYWORDS}")
    cmake_parse_arguments(DOX "" "" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

    if(NOT DOX_HEADER_CALLBACK)
        set(DOX_HEADER_CALLBACK doxygen_generate_file_header)
    endif()

    if(NOT DOX_FOOTER_CALLBACK)
        set(DOX_FOOTER_CALLBACK doxygen_generate_file_footer)
    endif()

    ## @cond
    function(doxygen_register_pattern_callback KEYWORD PATTERN CALLBACK)
        set(DOX_${KEYWORD}_PATTERN       ${PATTERN} PARENT_SCOPE)
        set(DOX_${KEYWORD}_CALLBACK      ${CALLBACK} PARENT_SCOPE)
        set(DOX_${KEYWORD}_CALLBACK_ARGS ${ARGN} PARENT_SCOPE)
    endfunction()
    ## @endcond

    foreach(KEYWORD IN LISTS MULTI_VALUE_KEYWORDS)
        if(DOX_${KEYWORD})
            # <pattern> <callback> [args]
            set(SIGNATURE ${DOX_${KEYWORD}})
            list(POP_FRONT SIGNATURE PATTERN)
            list(POP_FRONT SIGNATURE CALLBACK)
            set(CALLBACK_ARGS ${SIGNATURE})
            doxygen_register_pattern_callback(
                ${KEYWORD}
                ${PATTERN}
                ${CALLBACK}
                ${CALLBACK_ARGS})
        endif()
    endforeach()

    # register default callbacks
    set(__DOX_INTERNAL_KEYWORDS)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_EMPTY    "^ *$"                              doxygen_empty_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_EMPTY)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_COMMENT  "^##.*$"                            doxygen_comment_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_COMMENT)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_FUNCTION "^[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]" doxygen_function_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_FUNCTION)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_MACRO    "^[Mm][Aa][Cc][Rr][Oo]"             doxygen_macro_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_MACRO)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_OPTION   "^[Oo][Pp][Tt][Ii][Oo][Nn]"         doxygen_option_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_OPTION)
    doxygen_register_pattern_callback(INTERNAL_CMAKE_SET      "^[Ss][Ee][Tt] *\\(.*"              doxygen_set_callback)
    list(APPEND __DOX_INTERNAL_KEYWORDS INTERNAL_CMAKE_SET)

    # create the output file
    file(WRITE  ${DOX_OUTPUT} "")

    # generate file header
    cmake_language(CALL ${DOX_HEADER_CALLBACK} ${DOX_OUTPUT} ${DOX_INPUT})

    # parse the input file line by line
    file(STRINGS ${DOX_INPUT} LINES)
    set(DOX_LINE_INDEX 0)
    foreach(DOX_LINE IN LISTS LINES)
        string(STRIP "${DOX_LINE}" DOX_LINE)
        foreach(KEYWORD IN LISTS MULTI_VALUE_KEYWORDS __DOX_INTERNAL_KEYWORDS)
            if(DOX_${KEYWORD}_PATTERN AND DOX_${KEYWORD}_CALLBACK)
                if(DOX_LINE MATCHES ${DOX_${KEYWORD}_PATTERN})
                    cmake_language(CALL ${DOX_${KEYWORD}_CALLBACK}
                        ${DOX_OUTPUT}
                        ${DOX_INPUT}
                        ${DOX_LINE_INDEX}
                        "${DOX_LINE}"
                        ${DOX_${KEYWORD}_CALLBACK_ARGS})
                    break()
                endif()
            endif()
        endforeach()
        math(EXPR DOX_LINE_INDEX "${DOX_LINE_INDEX}+1")
    endforeach()

    # generate file footer
    cmake_language(CALL ${DOX_FOOTER_CALLBACK} ${DOX_OUTPUT} ${DOX_INPUT})
endfunction()