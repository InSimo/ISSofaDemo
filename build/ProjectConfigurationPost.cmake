# Executed at the end of the CMake configuration

# Install Pylint in the local python env of the build tree, useful for development
# (won't be installed in the install tree and packaged binaries).
# (using the -s option to ensure we install things in the local python env, to avoid
# polluting the system)
# We also install rope that can be useful for some auto-refactoring tasks in IDEs.
foreach( package_name pylint rope )
    message(STATUS "Installing ${package_name}")
    execute_process(COMMAND ${ISSOFAPYTHON_EXECUTABLE} -s -m pip install ${package_name})
endforeach()
