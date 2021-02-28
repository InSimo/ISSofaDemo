cmake_minimum_required(VERSION 3.1)

# Only used under msvc platform, to give a specific name to the solution file
set(SOLUTION_NAME "ISSofaDemo")

if(WIN32)
  # Windows uses SofaWinDependencies and ISExternals
  set(PROJECT_LIST_PLATFORM "IS/SofaWinDependencies;IS/ISExternals")
else()
  # Linux mostly use system-installed dependencies, expect for python in ISExternals
  set(PROJECT_LIST_PLATFORM "IS/ISExternals")
endif()

set(PROJECT_LIST "${PROJECT_LIST_PLATFORM};ISSofa;IS/ISSofaPython;IS/ISSofaGUI" CACHE STRING "A semicolon separated ordered list of projects to add to the build" FORCE)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../ISPhysics/build/CMakeLists.txt")
  list(APPEND PROJECT_LIST "IS/SofaConstraintLaws;ISPhysics")
  set(ISSOFAPYTHON_ADDITIONAL_SYS_PATH_DIRS
    ISPhysics/python           # isphysics and pyphysics
    ISPhysics/examples/shared  # common codes of ISPhysics example scenes
    CACHE STRING "A semicolon separated list of project dirs to add to the python sys.path" FORCE)
endif()

set(SOFA_OPTIONAL ON CACHE BOOL "Set to true to build sofa unused libraries" FORCE)
set(SOFA_USE_MINIBOOST ON CACHE BOOL "Set to true to use the header only minimal version of boost distributed in extlibs" FORCE)
set(SOFA_ENABLE_EASTL OFF CACHE BOOL "" FORCE)
# Disable the compilation of benchmark executbales in ISSofa/framework/framework_bench
# They don't compile with clang apparently, and besides the data required to run this benchmarks are not provided in this version
set(SOFA_ENABLE_BENCHMARKS OFF CACHE BOOL "" FORCE)

set(SOFA_EXTLIBS_TARGETS_DEFAULT glew-2.1.0;eigen-3.2.7;miniFlowVR;newmat;tinyxml;metis-5.1.0;csparse;qwt-6.0.1;gtest;cpu_features)
set(SOFA_EXTLIBS_TARGETS ${SOFA_EXTLIBS_TARGETS_DEFAULT} CACHE STRING "An ordered list (semicolon separated) list of sofa extlibs to add to the build." FORCE)