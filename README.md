# Doxygen For CMake

[![CMake Build](https://github.com/vrcomputing/Doxygen-For-CMake/actions/workflows/cmake.yml/badge.svg)](https://github.com/vrcomputing/Doxygen-For-CMake/actions/workflows/cmake.yml)

Parse CMake files for Doxygen documentation

## How it works

- Treat CMake files as Python files ( both languages use `#` for comments, both have keyword arguments )
    - Doxygen supports Python
- Parse CMake `function`, `macro` and `option` lines and generate Python functions/variables
- (Optional) Group CMake `function`, `macro` and `option` into Doxygen groups