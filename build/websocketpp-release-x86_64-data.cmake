########### AGGREGATED COMPONENTS AND DEPENDENCIES FOR THE MULTI CONFIG #####################
#############################################################################################

set(websocketpp_COMPONENT_NAMES "")
list(APPEND websocketpp_FIND_DEPENDENCY_NAMES OpenSSL Boost ZLIB)
list(REMOVE_DUPLICATES websocketpp_FIND_DEPENDENCY_NAMES)
set(OpenSSL_FIND_MODE "NO_MODULE")
set(Boost_FIND_MODE "NO_MODULE")
set(ZLIB_FIND_MODE "NO_MODULE")

########### VARIABLES #######################################################################
#############################################################################################
set(websocketpp_PACKAGE_FOLDER_RELEASE "/home/stdcapybara/.conan2/p/webso7a47c7731495b/p")
set(websocketpp_BUILD_MODULES_PATHS_RELEASE )


set(websocketpp_INCLUDE_DIRS_RELEASE "${websocketpp_PACKAGE_FOLDER_RELEASE}/include")
set(websocketpp_RES_DIRS_RELEASE )
set(websocketpp_DEFINITIONS_RELEASE )
set(websocketpp_SHARED_LINK_FLAGS_RELEASE )
set(websocketpp_EXE_LINK_FLAGS_RELEASE )
set(websocketpp_OBJECTS_RELEASE )
set(websocketpp_COMPILE_DEFINITIONS_RELEASE )
set(websocketpp_COMPILE_OPTIONS_C_RELEASE )
set(websocketpp_COMPILE_OPTIONS_CXX_RELEASE )
set(websocketpp_LIB_DIRS_RELEASE )
set(websocketpp_BIN_DIRS_RELEASE )
set(websocketpp_LIBRARY_TYPE_RELEASE UNKNOWN)
set(websocketpp_IS_HOST_WINDOWS_RELEASE 0)
set(websocketpp_LIBS_RELEASE )
set(websocketpp_SYSTEM_LIBS_RELEASE )
set(websocketpp_FRAMEWORK_DIRS_RELEASE )
set(websocketpp_FRAMEWORKS_RELEASE )
set(websocketpp_BUILD_DIRS_RELEASE )
set(websocketpp_NO_SONAME_MODE_RELEASE FALSE)


# COMPOUND VARIABLES
set(websocketpp_COMPILE_OPTIONS_RELEASE
    "$<$<COMPILE_LANGUAGE:CXX>:${websocketpp_COMPILE_OPTIONS_CXX_RELEASE}>"
    "$<$<COMPILE_LANGUAGE:C>:${websocketpp_COMPILE_OPTIONS_C_RELEASE}>")
set(websocketpp_LINKER_FLAGS_RELEASE
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:${websocketpp_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:${websocketpp_SHARED_LINK_FLAGS_RELEASE}>"
    "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:${websocketpp_EXE_LINK_FLAGS_RELEASE}>")


set(websocketpp_COMPONENTS_RELEASE )