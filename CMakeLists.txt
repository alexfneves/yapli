cmake_minimum_required(VERSION 3.13)

# Important: use the LANGUAGES argument
project(Yapli LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES 
      ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()


set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -gsource-map")


# Set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/public)

# Add source file
add_executable(out src/main.cpp)

# Use includes passed from environment
target_include_directories(out PRIVATE
    $ENV{INJA_INCLUDE_PATH}
    $ENV{JSON_INCLUDE_PATH}
)

# Pass Emscripten-specific flags to linker
set_target_properties(out PROPERTIES
    OUTPUT_NAME "out"
    LINK_FLAGS "--bind \
                -s WASM=1 \
                -s ALLOW_MEMORY_GROWTH=1 \
                -s MODULARIZE=1 \
                -s EXPORT_NAME=createModule \
                -s EXPORTED_RUNTIME_METHODS=ccall,cwrap \
                -s NO_DISABLE_EXCEPTION_CATCHING \
                -s ASSERTIONS=1 \
                -s EXCEPTION_STACK_TRACES=1 \
                -s DISABLE_EXCEPTION_THROWING=0 \
                --preload-file ${CMAKE_SOURCE_DIR}/templates@/ \
                -g"
)
