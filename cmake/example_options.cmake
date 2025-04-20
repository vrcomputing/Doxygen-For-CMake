## @brief CMake option without a value but a docstring
option(OPTION_1 "OPTION_1 Description")
## @brief CMake option with a value and a docstring
option(OPTION_2 "OPTION_2 Description" 2)
## @brief CMake option without a value but a docstring
option(OPTION_3 ${OPTION_2})
option(OPTION_4 "Description")

option(OPTION_5 X Y)