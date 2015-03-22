# Find the INCLULDE and LIBRARY path
find_path(ts3sdk_INCLUDE_DIR NAMES clientlib.h PATH_SUFFIXES bin)
list(APPEND ts3sdk_INCLUDE_DIRS ${ts3sdk_INCLUDE_DIR})

# Set the library to use
# Note: There is also a FreeBSD library which is not yet included
if (WIN32)
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(ts3sdk_client_LIBRARIES ts3client_amd64)
		set(ts3sdk_server_LIBRARIES ts3server_amd64)
		list(APPEND ts3sdk_soundbackend_LIBRARIES directsound_win64.dll)
		list(APPEND ts3sdk_soundbackend_LIBRARIES windowsaudiosession_win64.dll)
	else()
		set(ts3sdk_client_LIBRARIES ts3client_win32)
		set(ts3sdk_server_LIBRARIES ts3server_win32)
		list(APPEND ts3sdk_soundbackend_LIBRARIES directsound_win32.dll)
		list(APPEND ts3sdk_soundbackend_LIBRARIES windowsaudiosession_win32.dll)
	endif()
elseif (APPLE)
	set(ts3sdk_client_LIBRARIES ts3client_mac)
	set(ts3sdk_server_LIBRARIES ts3server_mac)
	list(APPEND ts3sdk_soundbackend_LIBRARIES libcoreaudio_mac.dylib)
elseif (UNIX)
	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(ts3sdk_client_LIBRARIES ts3client_linux_amd64)
		set(ts3sdk_server_LIBRARIES ts3server_linux_amd64)
		list(APPEND ts3sdk_soundbackend_LIBRARIES libalsa_linux_amd64.so)
		list(APPEND ts3sdk_soundbackend_LIBRARIES libpulseaudio_linux_amd64.so)
	else()
		set(ts3sdk_client_LIBRARIES ts3client_linux_x86)
		set(ts3sdk_server_LIBRARIES ts3server_linux_x86)
		list(APPEND ts3sdk_soundbackend_LIBRARIES libalsa_linux_x86.so)
		list(APPEND ts3sdk_soundbackend_LIBRARIES libpulseaudio_linux_x86.so)
	endif()
endif()

foreach(ts3sdk_COMPONENT ${ts3sdk_FIND_COMPONENTS})
	if(${ts3sdk_COMPONENT} STREQUAL "client")
		list(APPEND ts3sdk_LIBRARIES ${ts3sdk_client_LIBRARIES})
	elseif(${ts3sdk_COMPONENT} STREQUAL "server")
		list(APPEND ts3sdk_LIBRARIES ${ts3sdk_server_LIBRARIES})
	endif()
endforeach(ts3sdk_COMPONENT)

message(STATUS "ts3sdk headers found in " ${ts3sdk_INCLUDE_DIRS})
message(STATUS "ts3sdk libraries used: " ${ts3sdk_LIBRARIES})

# Get the library file information
foreach(ts3sdk_LIBRARY ${ts3sdk_LIBRARIES})
	add_library(${ts3sdk_LIBRARY} SHARED IMPORTED)
	find_library(FOUND_${ts3sdk_LIBRARY} NAME ${ts3sdk_LIBRARY} PATH_SUFFIXES bin)
	message(STATUS "Found Library File for " ${ts3sdk_LIBRARY} " at " ${FOUND_${ts3sdk_LIBRARY}})
	
	if (WIN32)
		# For windows, we found the LIB file. Set it as IMPORTED_IMPLIB.
		set_target_properties(${ts3sdk_LIBRARY} PROPERTIES IMPORTED_IMPLIB ${FOUND_${ts3sdk_LIBRARY}})
		
		# Heuristically get the name and location of the corresponding DLL file, so a project can copy the file
		get_filename_component(FOUND_${ts3sdk_LIBRARY}_DIR ${FOUND_${ts3sdk_LIBRARY}} DIRECTORY)
		get_filename_component(FOUND_${ts3sdk_LIBRARY}_FILENAME ${FOUND_${ts3sdk_LIBRARY}} NAME_WE)
		find_file(FOUND_${ts3sdk_LIBRARY}_FILE NAMES ${FOUND_${ts3sdk_LIBRARY}_FILENAME}.dll PATHS PATH_SUFFIXES bin)
		
		message(STATUS "Found DLL file for " ${ts3sdk_LIBRARY} " at " ${FOUND_${ts3sdk_LIBRARY}_FILE})
		set_target_properties(${ts3sdk_LIBRARY} PROPERTIES IMPORTED_LOCATION ${FOUND_${ts3sdk_LIBRARY}_FILE})
		list(APPEND ts3sdk_LIBRARY_FILES ${FOUND_${ts3sdk_LIBRARY}_FILE_FULL})
	else()
		# For other systems, we just set the .so/.dylib file we found.
		set_target_properties(${ts3sdk_LIBRARY} PROPERTIES IMPORTED_LOCATION ${FOUND_${ts3sdk_LIBRARY}})
		list(APPEND ts3sdk_LIBRARY_FILES ${FOUND_${ts3sdk_LIBRARY}})
	endif()
endforeach(ts3sdk_LIBRARY)

# Add the relevant libraries from the sound plugins
set(ts3sdk_soundbackend_LIBRARIES_DIR_TARGETNAME "soundbackends")
message(STATUS "Looking for Soundbackends: " ${ts3sdk_soundbackend_LIBRARIES})
find_path(ts3sdk_soundbackend_LIBRARIES_DIR NAMES ${ts3sdk_soundbackend_LIBRARIES} PATH_SUFFIXES bin/${ts3sdk_soundbackend_LIBRARIES_DIR_TARGETNAME})
message(STATUS "Soundbackend Directory: " ${ts3sdk_soundbackend_LIBRARIES_DIR})