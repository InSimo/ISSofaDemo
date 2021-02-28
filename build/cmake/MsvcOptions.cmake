# Compiler options for MSVC compiler

if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /wd4244 /wd4250 /wd4251 /wd4267 /wd4275 /wd4503 /wd4675 /wd4996 /bigobj")
    
    set ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /fp:fast" )
    set ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP /fp:fast" )
    
    set (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DSOFA_DEBUG")
    set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DSOFA_DEBUG")
    
endif()
