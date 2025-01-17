cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "sqlite3_vec")
project(${PROJECT_NAME} LANGUAGES CXX C)

set(PLUGIN_NAME "sqlite3_vec_plugin")

# Plugin sources
list(APPEND PLUGIN_SOURCES
  "sqlite3_vec_plugin.cc"
)

# Fetch SQLite and Vec libraries
include(FetchContent)
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
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

# Generate Vec header
add_custom_command(
    OUTPUT ${vec0_SOURCE_DIR}/sqlite-vec.h
    COMMAND make sqlite-vec.h
    WORKING_DIRECTORY ${vec0_SOURCE_DIR}
    COMMENT "Building sqlite-vec.h with make"
)

add_custom_target(generate_vec_header
    DEPENDS ${vec0_SOURCE_DIR}/sqlite-vec.h
)

# Build Vec library
add_library(vec0 
    SHARED 
    ${vec0_SOURCE_DIR}/sqlite-vec.c
)

add_dependencies(vec0 generate_vec_header)

target_include_directories(vec0 
    PRIVATE 
    ${vec0_SOURCE_DIR}
    ${sqlite3_SOURCE_DIR}
)

target_compile_options(vec0 
    PRIVATE 
    -Wall 
    -Wextra 
    -O3
)

# Plugin library
add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE vec0)

# Bundle the vec0 library
set(sqlite3_vec_bundled_libraries
  "$<TARGET_FILE:vec0>"
  PARENT_SCOPE
)

# Tests section remains unchanged
if (${include_${PROJECT_NAME}_tests})
if(${CMAKE_VERSION} VERSION_LESS "3.11.0")
message("Unit tests require CMake 3.11.0 or later")
else()
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Add the Google Test dependency.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)

FetchContent_MakeAvailable(googletest)

# The plugin's exported API is not very useful for unit testing, so build the
# sources directly into the test binary rather than using the shared library.
add_executable(${TEST_RUNNER}
  test/sqlite3_vec_plugin_test.cc
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter)
target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::GTK)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})

endif()  # CMake version check
endif()  # include_${PROJECT_NAME}_tests