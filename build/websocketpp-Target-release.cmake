# Avoid multiple calls to find_package to append duplicated properties to the targets
include_guard()########### VARIABLES #######################################################################
#############################################################################################
set(websocketpp_FRAMEWORKS_FOUND_RELEASE "") # Will be filled later
conan_find_apple_frameworks(websocketpp_FRAMEWORKS_FOUND_RELEASE "${websocketpp_FRAMEWORKS_RELEASE}" "${websocketpp_FRAMEWORK_DIRS_RELEASE}")

set(websocketpp_LIBRARIES_TARGETS "") # Will be filled later


######## Create an interface target to contain all the dependencies (frameworks, system and conan deps)
if(NOT TARGET websocketpp_DEPS_TARGET)
    add_library(websocketpp_DEPS_TARGET INTERFACE IMPORTED)
endif()

set_property(TARGET websocketpp_DEPS_TARGET
             PROPERTY INTERFACE_LINK_LIBRARIES
             $<$<CONFIG:Release>:${websocketpp_FRAMEWORKS_FOUND_RELEASE}>
             $<$<CONFIG:Release>:${websocketpp_SYSTEM_LIBS_RELEASE}>
             $<$<CONFIG:Release>:openssl::openssl;ZLIB::ZLIB;Boost::headers>
             APPEND)

####### Find the libraries declared in cpp_info.libs, create an IMPORTED target for each one and link the
####### websocketpp_DEPS_TARGET to all of them
conan_package_library_targets("${websocketpp_LIBS_RELEASE}"    # libraries
                              "${websocketpp_LIB_DIRS_RELEASE}" # package_libdir
                              "${websocketpp_BIN_DIRS_RELEASE}" # package_bindir
                              "${websocketpp_LIBRARY_TYPE_RELEASE}"
                              "${websocketpp_IS_HOST_WINDOWS_RELEASE}"
                              websocketpp_DEPS_TARGET
                              websocketpp_LIBRARIES_TARGETS  # out_libraries_targets
                              "_RELEASE"
                              "websocketpp"    # package_name
                              "${websocketpp_NO_SONAME_MODE_RELEASE}")  # soname

# FIXME: What is the result of this for multi-config? All configs adding themselves to path?
set(CMAKE_MODULE_PATH ${websocketpp_BUILD_DIRS_RELEASE} ${CMAKE_MODULE_PATH})

########## GLOBAL TARGET PROPERTIES Release ########################################
    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_LINK_LIBRARIES
                 $<$<CONFIG:Release>:${websocketpp_OBJECTS_RELEASE}>
                 $<$<CONFIG:Release>:${websocketpp_LIBRARIES_TARGETS}>
                 APPEND)

    if("${websocketpp_LIBS_RELEASE}" STREQUAL "")
        # If the package is not declaring any "cpp_info.libs" the package deps, system libs,
        # frameworks etc are not linked to the imported targets and we need to do it to the
        # global target
        set_property(TARGET websocketpp::websocketpp
                     PROPERTY INTERFACE_LINK_LIBRARIES
                     websocketpp_DEPS_TARGET
                     APPEND)
    endif()

    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_LINK_OPTIONS
                 $<$<CONFIG:Release>:${websocketpp_LINKER_FLAGS_RELEASE}> APPEND)
    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                 $<$<CONFIG:Release>:${websocketpp_INCLUDE_DIRS_RELEASE}> APPEND)
    # Necessary to find LINK shared libraries in Linux
    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_LINK_DIRECTORIES
                 $<$<CONFIG:Release>:${websocketpp_LIB_DIRS_RELEASE}> APPEND)
    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_COMPILE_DEFINITIONS
                 $<$<CONFIG:Release>:${websocketpp_COMPILE_DEFINITIONS_RELEASE}> APPEND)
    set_property(TARGET websocketpp::websocketpp
                 PROPERTY INTERFACE_COMPILE_OPTIONS
                 $<$<CONFIG:Release>:${websocketpp_COMPILE_OPTIONS_RELEASE}> APPEND)

########## For the modules (FindXXX)
set(websocketpp_LIBRARIES_RELEASE websocketpp::websocketpp)
