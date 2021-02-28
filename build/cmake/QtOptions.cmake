# Qt
# support for 32-bits and 64-bits compilation on windows without switching PATH and other variables
# we look for QTDIR32 or QTDIR64, and use them if they exists
# We cannot do this in ISSofaGUI only, as Qwt is currently compiled as part of ISSofa
if (MSVC)
  set(QTDIR "")
  if (CMAKE_CL_64 AND DEFINED ENV{QTDIR64})
    file(TO_CMAKE_PATH "$ENV{QTDIR64}" QTDIR)
    set(ENV{QTDIR} "$ENV{QTDIR64}") # copy QTDIR64 to QTDIR var to be used by FindQt
  elseif ((NOT CMAKE_CL_64) AND DEFINED ENV{QTDIR32})
    file(TO_CMAKE_PATH "$ENV{QTDIR32}" QTDIR)
    set(ENV{QTDIR} "$ENV{QTDIR32}") # copy QTDIR32 to QTDIR var to be used by FindQt
  elseif (DEFINED ENV{QTDIR})
    file(TO_CMAKE_PATH "$ENV{QTDIR}" QTDIR)
  endif()
  if (NOT ("${QTDIR}" STREQUAL ""))
    message(STATUS "QTDIR: ${QTDIR}")
    set(QT_QMAKE_EXECUTABLE "${QTDIR}/bin/qmake.exe" CACHE PATH "Path to qmake executable, used as a hint to find matching libraries")
  endif()
  find_package(Qt4)
  if(Qt4_FOUND)
    message(STATUS "Qt4 FOUND")
  endif()
endif()
