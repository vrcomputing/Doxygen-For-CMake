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

function(doxygen_generate_file_header OUTPUT_FILENAME INPUT_FILENAME)
    get_filename_component(FILENAME ${INPUT_FILENAME} NAME)
    file(WRITE  ${OUTPUT_FILENAME} "")
    file(APPEND ${OUTPUT_FILENAME} "# THIS FILE IS GENERATED!\n\n")
    file(APPEND ${OUTPUT_FILENAME} "## @file ${FILENAME}\n\n")
endfunction()

function(doxygen_generate_file_footer OUTPUT_FILENAME INPUT_FILENAME)
    file(APPEND ${OUTPUT_FILENAME} "# THIS FILE IS GENERATED!\n\n")
endfunction()

function(doxygen_empty_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "\n")
endfunction()

function(doxygen_comment_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "${INPUT_LINE}\n")
endfunction()

function(doxygen_function_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)
    list(JOIN TOKENS ", " METHOD_ARGS)
    file(APPEND ${OUTPUT_FILENAME} "def ${METHOD_NAME}(${METHOD_ARGS}):\n\tpass\n\n")
endfunction()

function(doxygen_macro_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    doxygen_tokenize(${INPUT_LINE} TOKENS)
    list(POP_FRONT TOKENS METHOD_TYPE)
    list(POP_FRONT TOKENS METHOD_NAME)
    list(JOIN TOKENS ", " METHOD_ARGS)
    file(APPEND ${OUTPUT_FILENAME} "def ${METHOD_NAME}(${METHOD_ARGS}):\n\tpass\n\n")
endfunction()

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
        file(APPEND ${OUTPUT_FILENAME} "${METHOD_NAME} = ${METHOD_ARGS}\n\n")
    endif()
endfunction()

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

function(doxygen_generate_cmake DOX_INPUT DOX_OUTPUT MULTI_VALUE_KEYWORDS)
    string(REPLACE "," ";" MULTI_VALUE_KEYWORDS "${MULTI_VALUE_KEYWORDS}")
    cmake_parse_arguments(DOX "" "" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

    if(NOT DOX_HEADER_CALLBACK)
        set(DOX_HEADER_CALLBACK doxygen_generate_file_header)
    endif()

    if(NOT DOX_FOOTER_CALLBACK)
        set(DOX_FOOTER_CALLBACK doxygen_generate_file_footer)
    endif()

    function(doxygen_register_pattern_callback KEYWORD PATTERN CALLBACK)
        set(DOX_${KEYWORD}_PATTERN       ${PATTERN} PARENT_SCOPE)
        set(DOX_${KEYWORD}_CALLBACK      ${CALLBACK} PARENT_SCOPE)
        set(DOX_${KEYWORD}_CALLBACK_ARGS ${ARGN} PARENT_SCOPE)
    endfunction()

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