cmake_minimum_required(VERSION 3.10)

# Set the project name
project(sqlite_vec)

# Set default compiler if not provided
if(NOT CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER gcc)
endif()

# Configure Android specific settings
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

include(FetchContent)
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  # cmake 3.24.0 added the `DOWNLOAD_EXTRACT_TIMESTAMP` and prints an ugly warning when
  # the default is used, so override it to the recommended behavior.
  # We can't really ask users to use a cmake that recent, so there's this if here.
  FetchContent_Declare(
    sqlite3
    URL https://sqlite.org/2024/sqlite-autoconf-3470200.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP NEW
  )

  FetchContent_Declare(
    vec0
    URL https://github.com/asg017/sqlite-vec/archive/refs/tags/v0.1.7-alpha.2.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP NEW
  )
else()
  FetchContent_Declare(
    sqlite3
    URL https://sqlite.org/2024/sqlite-autoconf-3470200.tar.gz
  )

  FetchContent_Declare(
    vec0
    URL https://github.com/asg017/sqlite-vec/archive/refs/tags/v0.1.7-alpha.2.tar.gz
  )
endif()

FetchContent_MakeAvailable(sqlite3)
FetchContent_MakeAvailable(vec0)

add_custom_command(
    OUTPUT ${vec0_SOURCE_DIR}/sqlite-vec.h
    COMMAND make sqlite-vec.h
    WORKING_DIRECTORY ${vec0_SOURCE_DIR}
    COMMENT "Building sqlite-vec.h with make"
)

add_custom_target(generate_vec_header
    DEPENDS ${vec0_SOURCE_DIR}/sqlite-vec.h
)

add_library(vec0 
    SHARED 
    ${vec0_SOURCE_DIR}/sqlite-vec.c
)

add_dependencies(vec0 generate_vec_header)

# Include directories
target_include_directories(vec0 
    PRIVATE 
    ${vec0_SOURCE_DIR}
    ${sqlite3_SOURCE_DIR}
)

# Set compile options
target_compile_options(vec0 
    PRIVATE 
    -Wall 
    -Wextra 
    -O3
)
