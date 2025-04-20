# Doxygen For CMake

[![CMake Build](https://github.com/vrcomputing/Doxygen-For-CMake/actions/workflows/cmake.yml/badge.svg)](https://github.com/vrcomputing/Doxygen-For-CMake/actions/workflows/cmake.yml)

Parse CMake files for Doxygen documentation

## How it works

- Add CMake file to the Doxygen file patterns
```cmake
set(DOXYGEN_FILE_PATTERNS
    [[CMakeLists.txt]]
    [[*.cmake]]
    )
```
- Treat CMake files as Python files
    - both languages use `#` for comments
    - both languages have keyword arguments
    - Doxygen supports Python
```cmake
set(DOXYGEN_EXTENSION_MAPPING
    [[txt=Python]]
    [[cmake=Python]]
    )
```
- Parse CMake `function`, `macro`, `option`, `set` lines and generate Python functions/variables
```cmake
# input filename
set(INPUT_FILENAME  ${CMAKE_CURRENT_LIST_DIR}/cmake/example.cmake)
# output filename for generated python output
set(OUTPUT_FILENAME ${CMAKE_CURRENT_BINARY_DIR}/cmake/example.cmake)
# custom keywords for registering patterns and callbacks
set(KEYWORDS "")

# generate python file with entities and Doxygen comments
doxygen_generate_cmake(${INPUT_FILENAME} ${OUTPUT_FILENAME} ${KEYWORDS})

# finally generate the actual doxygen documentation
doxygen_add_docs(doxygen ${OUTPUT_FILENAME})
```

## Customization

The `doxygen_generate_cmake` allows registering custom callbacks for RegEx patterns thereby enabling you to add/override how to react on parsed lines.

```cmake
doxygen_generate_cmake(
    ${INPUT_FILENAME} ${OUTPUT_FILENAME}
    # declare pattern for callback
    "CMAKE_EMPTY,CMAKE_COMMENT,CMAKE_FUNCTION,CMAKE_MACRO,CMAKE_OPTION,CMAKE_SET"
    # <mv-keyword> <pattern>                           <callback>               <args>
    CMAKE_COMMENT  "^##.*$"                            custom_comment_callback  CUSTOM
    CMAKE_FUNCTION "^[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]" custom_function_callback
    CMAKE_MACRO    "^[Mm][Aa][Cc][Rr][Oo]"             custom_macro_callback
    CMAKE_OPTION   "^[Oo][Pp][Tt][Ii][Oo][Nn]"         custom_option_callback
    CMAKE_SET      "^[Ss][Ee][Tt] *\\(.*"              custom_set_callback
)
```

> `mv-keyword` for multi value keyword [cmake_parse_arguments](https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html)

Callbacks will be called with a fixed set of arguments followed by a set of optional arguments that you can define.

```cmake
## @brief Custom callback for a line that matches comment pattern
## @param OUTPUT_FILENAME  The output file for generating code into
## @param INPUT_FILENAME   The input file being parsed
## @param INPUT_LINE_INDEX The line index of the matched line from the input file
## @param INPUT_LINE       The matched line from the input file
function(custom_comment_callback OUTPUT_FILENAME INPUT_FILENAME INPUT_LINE_INDEX INPUT_LINE)
    file(APPEND ${OUTPUT_FILENAME} "${INPUT_LINE}\n")
    cmake_parse_arguments(CCC "CUSTOM" "" "" ${ARGN})
    if(CCC_CUSTOM)
        message(DEBUG "CUSTOM received")
    endif()
endfunction()
```

# Further Reading

- [doxygen_add_docs](https://cmake.org/cmake/help/latest/module/FindDoxygen.html)
- [cmake_parse_arguments](https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html)