# Find the INCLULDE and LIBRARY path
find_path(ts3sdk_INCLUDE_DIR NAMES clientlib.h HINTS ${CMAKE_PREFIX_PATH}/include)
list(APPEND ts3sdk_INCLUDE_DIRS ${ts3sdk_INCLUDE_DIR})

# Set the library to use
# Note: There is also a FreeBSD library which is not yet included
if (WIN32)
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(ts3sdk_client_LIBRARIES ts3client_amd64)
		set(ts3sdk_server_LIBRARIES ts3server_amd64)
	else()
		set(ts3sdk_client_LIBRARIES ts3client_win32)
		set(ts3sdk_server_LIBRARIES ts3server_win32)
	endif()
elseif (APPLE)
	set(ts3sdk_client_LIBRARIES ts3client_mac)
	set(ts3sdk_server_LIBRARIES ts3server_mac)
elseif (UNIX)
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(ts3sdk_client_LIBRARIES ts3client_linux_amd64)
		set(ts3sdk_server_LIBRARIES ts3server_linux_amd64)
	else()
		set(ts3sdk_client_LIBRARIES ts3client_linux_x86)
		set(ts3sdk_server_LIBRARIES ts3server_linux_x86)
	endif()
endif()

foreach(ts3sdk_COMPONENT ${ts3sdk_FIND_COMPONENTS})
	if(${ts3sdk_COMPONENT} STREQUAL "client")
		list(APPEND ts3sdk_LIBRARIES ${ts3sdk_client_LIBRARIES})
	elseif(${ts3sdk_COMPONENT} STREQUAL "server")
		list(APPEND ts3sdk_LIBRARIES ${ts3sdk_server_LIBRARIES})
	endif()
endforeach(ts3sdk_COMPONENT)

# TODO: Add the relevant libraries from the sound plugins

message(STATUS "ts3sdk headers found in " ${ts3sdk_INCLUDE_DIRS})
message(STATUS "ts3sdk libraries used: " ${ts3sdk_LIBRARIES})

# Get the library file information
foreach(ts3sdk_LIBRARY ${ts3sdk_LIBRARIES})
	add_library(${ts3sdk_LIBRARY} SHARED IMPORTED)
	find_library(FOUND_${ts3sdk_LIBRARY} NAME ${ts3sdk_LIBRARY} HINTS ${CMAKE_PREFIX_PATH}/bin)
	message(STATUS "Found Library File for " ${ts3sdk_LIBRARY} " at " ${FOUND_${ts3sdk_LIBRARY}})
	list(APPEND ts3sdk_LIBRARY_FILES ${FOUND_${ts3sdk_LIBRARY}})
	if (WIN32)
		set_target_properties(${ts3sdk_LIBRARY} PROPERTIES IMPORTED_IMPLIB ${FOUND_${ts3sdk_LIBRARY}})
		# How to find the DLL file and store it in IMPORTED_LOCATION?
	else()
		set_target_properties(${ts3sdk_LIBRARY} PROPERTIES IMPORTED_LOCATION ${FOUND_${ts3sdk_LIBRARY}})
	endif()
endforeach(ts3sdk_LIBRARY)

