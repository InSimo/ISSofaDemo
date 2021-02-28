cmake_minimum_required(VERSION 3.1)

# Use C++14 by default
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # ensure -std=c++14 rather than -std=gnu++14 with g++
message(STATUS "C++ standard set to C++14")

# platforms checks are performed within each  file,
# so we just include each options
include(GccOptions)
include(MsvcOptions)
include(FastbuildOptions)
include(QtOptions)
