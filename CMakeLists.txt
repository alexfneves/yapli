cmake_minimum_required(VERSION 3.13)
project(yapli LANGUAGES CXX)

# C++ configuration
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES 
      ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()


# Debug info & output
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/public)

# Source file
set(SRC ${CMAKE_SOURCE_DIR}/src/main.cpp)

# List all files in templates/ for dependency tracking
file(GLOB_RECURSE PRELOAD_FILES "${CMAKE_SOURCE_DIR}/templates/*")

# Output files
set(OUT_JS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/out.js)
set(OUT_WASM ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/out.wasm)

# Compile with em++ manually using a custom command
add_custom_command(
    OUTPUT ${OUT_JS} ${OUT_WASM}
    COMMAND ${CMAKE_CXX_COMPILER}
        -I$ENV{INJA_INCLUDE_PATH}
        -I$ENV{JSON_INCLUDE_PATH}
        ${SRC}
        -o ${OUT_JS}
        --bind
        -s WASM=1
        -s ALLOW_MEMORY_GROWTH=1
        -s MODULARIZE=1
        -s EXPORT_NAME=createModule
        -s EXPORTED_RUNTIME_METHODS=ccall,cwrap
        -s NO_DISABLE_EXCEPTION_CATCHING
        -s ASSERTIONS=1
        -s EXCEPTION_STACK_TRACES=1
        -s DISABLE_EXCEPTION_THROWING=0
        -g
        -gsource-map
        --preload-file ${CMAKE_SOURCE_DIR}/templates@/
    DEPENDS ${SRC} ${PRELOAD_FILES}
    COMMENT "Building WASM with preloaded files and includes"
)

# Custom build target
add_custom_target(out ALL
    DEPENDS ${OUT_JS} ${OUT_WASM}
)

# Dummy target to force compile_commands.json generation
add_executable(out_exec EXCLUDE_FROM_ALL ${SRC})
target_include_directories(out_exec PRIVATE
    $ENV{INJA_INCLUDE_PATH}
    $ENV{JSON_INCLUDE_PATH}
)
