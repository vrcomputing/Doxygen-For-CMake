# variables

## @brief Variable with no value
set(VARIABLE_0)
## @brief Variable with one value
set(VARIABLE_1 1)
## @brief Variable with multiple values
set(VARIABLE_N 1 2 3 4 5)
## @brief Variable with a lot of whitespace
set      (  VARIABLE_X  1   2    3   4   5    )

## @cond
function(example_scope)
## @endcond
## @brief Variable set in parent's scope
set(VARIABLE_P "String value" PARENT_SCOPE)
## @cond
endfunction()
## @endcond

set(VARIABLE_UNDOCUMENTED)

# cache variables

## @brief Cache variable with no value
set(CACHE_VARIABLE_0   CACHE STRING "Brief description here" FORCE)
## @brief Cache variable with one value
set(CACHE_VARIABLE_1 1 CACHE STRING "Brief description here" FORCE)

