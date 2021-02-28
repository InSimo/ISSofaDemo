# compiler options for GCC

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")

    if(CMAKE_CXX_COMPILER_ARG1)
        # in the case of CXX="ccache g++"
        string(STRIP ${CMAKE_CXX_COMPILER_ARG1} CMAKE_CXX_COMPILER_ARG1_stripped)
        execute_process(COMMAND ${CMAKE_CXX_COMPILER_ARG1_stripped} -dumpfullversion -dumpversion OUTPUT_VARIABLE GCXX_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
    else()
        execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpfullversion -dumpversion OUTPUT_VARIABLE GCXX_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    message(STATUS "g++ version: ${GCXX_VERSION}")

    # reorder warnings became too numerous, it is too much of a pain to fix all the time...
    set(CXX_WARNING_FLAGS "-Wall -Wextra -pedantic -Wno-reorder")
    set(CXX_DEBUG_FLAGS "-g")
    set(CXX_SOFA_DEBUG_FLAGS "-DSOFA_DEBUG")
    #set(CXX_PROFILING_FLAGS "-fno-omit-frame-pointer -DNDEBUG")
    set(CXX_OPTIMIZATION_FLAGS "-O2 -DNDEBUG")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_WARNING_FLAGS}")
    
    # Linker options
    set(USE_GOLD_LINKER TRUE CACHE BOOL "Use gold linker instead of default ld linker")
    if(USE_GOLD_LINKER)
      execute_process(COMMAND ${CMAKE_CXX_COMPILER} -fuse-ld=gold -Wl,--version ERROR_QUIET OUTPUT_VARIABLE LD_VERSION)
      if(LD_VERSION MATCHES "GNU gold")
          set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=gold")
          set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=gold")
          set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -fuse-ld=gold")
      else()
          message(WARNING "gold linker not available")
      endif()
    endif()

    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        # Do not limit maximum number of template instantiation notes for a single warning or error
        # Disable too numerous warnings : do not warn about missing override keyword, or about hidden overloaded virtual functions
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftemplate-backtrace-limit=0 -Wno-inconsistent-missing-override -Wno-overloaded-virtual")
    endif()

    if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND  "${GCXX_VERSION}" VERSION_GREATER_EQUAL 9.0)
        # with gcc 9.0+ many warnings are generated when using default copy constructors / assign operators in classes with user-defined constructors
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-copy")
    endif()

    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${CXX_DEBUG_FLAGS} ${CXX_SOFA_DEBUG_FLAGS}")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${CXX_DEBUG_FLAGS} ${CXX_SOFA_DEBUG_FLAGS}")
    
    elseif(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo") 
        set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CXX_OPTIMIZATION_FLAGS} ${CXX_DEBUG_FLAGS} ${CXX_ARCH_FLAGS}" )

    elseif(CMAKE_BUILD_TYPE MATCHES "Release")
        set(CXX_STACKPROTECTOR_FLAGS "-fstack-protector --param=ssp-buffer-size=4")
        set(CXX_FORTIFYSOURCE_FLAGS  "-D_FORTIFY_SOURCE=2")
        
        set(CMAKE_CXX_FLAGS_RELEASE "${CXX_OPTIMIZATION_FLAGS} ${CXX_ARCH_FLAGS} ${CXX_STACKPROTECTOR_FLAGS} ${CXX_FORTIFYSOURCE_FLAGS}")
        # disable partial inlining under gcc 4.6
        if("${GCXX_VERSION}" VERSION_EQUAL 4.6)
            set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-partial-inlining")
        endif()
        set ( CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-undefined -lc ${CMAKE_SHARED_LINKER_FLAGS}")
        set ( CMAKE_MODULE_LINKER_FLAGS "-Wl,--no-undefined -lc ${CMAKE_MODULE_LINKER_FLAGS}")
    
    elseif(CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    endif()

    # Enable relative RPATH on built and installed binaries, so that nothing is
    # tied to absolute paths and no LD_LIBRARY_PATH adjustement is required to
    # find dependencies.
    # See https://cmake.org/Wiki/CMake_RPATH_handling
    set(CMAKE_CMAKE_SKIP_BUILD_RPATH FALSE)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib:${CMAKE_INSTALL_RPATH}")
endif()
