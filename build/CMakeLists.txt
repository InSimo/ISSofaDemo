cmake_minimum_required(VERSION 3.9.6)

include(ProjectConfiguration.cmake)
project(${SOLUTION_NAME})

# In source build are not allowed
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. \ 
            Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt.")
endif()

# MSVC: Use solution folders.
if(CMAKE_GENERATOR MATCHES "Visual Studio|Fastbuild")
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

# Get parent directory (cleaner than appending "/..")
get_filename_component(PROJECT_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY)

if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
  set( CMAKE_INSTALL_PREFIX ${PROJECT_ROOT_DIR} CACHE PATH "Install path prefix, prepended onto install directories." FORCE )
endif (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )

message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

if( WIN32 )
  # To avoid having to separately install dependencies such as the VC++ redistributables,
  # we embed the compiler-provided system runtime libraries (vcruntime DLL, api-mw-win-* DLLs, ...)
  # (not putting this in a if(MSVC) because it could theoretically be useful in other contexts)
  include(GNUInstallDirs)
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP FALSE)
  set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION ${CMAKE_INSTALL_BINDIR})
  include(InstallRequiredSystemLibraries)
endif()

# Set the output directories globally
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Environment
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CompilerOptions)
set(PROJECT_LIST "" CACHE STRING "A semicolon separated ordered list of projects to add to the build" )

if(NOT PROJECT_LIST)
    message(WARNING "PROJECT_LIST CACHE variable is currently empty.\nThis CACHE variable must be edited in ${CMAKE_CURRENT_LIST_FILE} \
                     to declare an ordered list of directories, relative from ${PROJECT_ROOT_DIR}, that need to be added to the build. \
                     The script will then for each directory specified in this list, look for a CMakelists.txt file in two possible locations:\n \
                     1- the build/ folder of the directory.\n \
                     2- the root folder of the directory.")
endif()

if(BUILD_TESTING)
    enable_testing()
endif()

foreach(proj ${PROJECT_LIST} )
    if( EXISTS "${PROJECT_ROOT_DIR}/${proj}/build/CMakeLists.txt")
        add_subdirectory( "${PROJECT_ROOT_DIR}/${proj}/build" ${CMAKE_CURRENT_BINARY_DIR}/${proj} )
    elseif(EXISTS "${PROJECT_ROOT_DIR}/${proj}/CMakeLists.txt")
        add_subdirectory( ${PROJECT_ROOT_DIR}/${proj} ${CMAKE_CURRENT_BINARY_DIR}/${proj} )
    else()
        message(WARNING "Could not find a CMakelists.txt for project ${proj} from root directory ${PROJECT_ROOT_DIR}")
    endif()
endforeach()

# Write a config file to provide the relative path to the binaries for launcher and packaging scripts
file( RELATIVE_PATH build_config_binary_dir ${PROJECT_ROOT_DIR} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} )
message(STATUS "Creating/updating the .bin.json file")
execute_process(
    COMMAND
    ${ISSOFAPYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/update_bin_json_file.py "${build_config_binary_dir}"
    RESULT_VARIABLE UPDATE_BIN_JSON_FILE_RC
)
if(UPDATE_BIN_JSON_FILE_RC)
    message(FATAL_ERROR "Creation or update of the .bin.json file failed with code ${UPDATE_BIN_JSON_FILE_RC}")
endif()

find_package(ISSofaPython REQUIRED)
set(PYTHON_REQUIREMENTS_FILE ${PROJECT_ROOT_DIR}/python_requirements.txt)
issofapython_install_requirements(${PYTHON_REQUIREMENTS_FILE})


# At build time, in case of a multi-config generator, let's add the build config name into the '.bin.json' file
# to make it easier for scripts to determine the actual directory containing the binaries.
# (we don't have this information at configure time)
get_property(_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if( _GENERATOR_IS_MULTI_CONFIG )
    add_custom_target(UpdateBinDir ALL COMMENT "Updating the .bin.json file")
    add_custom_command(
        TARGET UpdateBinDir POST_BUILD
        COMMAND ${ISSOFAPYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/update_bin_json_file.py "${build_config_binary_dir}/$<CONFIG>")
endif()

# Project-specific global post configuration
if( EXISTS "${CMAKE_SOURCE_DIR}/ProjectConfigurationPost.cmake" )
    include(ProjectConfigurationPost.cmake)
else()
    message(STATUS "No ProjectConfigurationPost.cmake")
endif()
