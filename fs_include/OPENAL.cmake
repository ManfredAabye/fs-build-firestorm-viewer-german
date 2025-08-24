# -*- cmake -*-
include(Linking)
include(Prebuilt)

include_guard()

## OpenAL ist standardmaessig deaktiviert. Aktivierung über USE_OPENAL moeglich.

set(USE_OPENAL ON CACHE BOOL "Enable OpenAL")

# <FS:Zi> Always download the libopenal.so library on Linux for SLVoice
if (LINUX)
  use_prebuilt_binary(openal)
endif (LINUX)

# Kompatibilitaet: Wenn OPENAL gesetzt wird, nutze auch USE_OPENAL
if(OPENAL)
  set(USE_OPENAL ${OPENAL})
endif()

if (USE_OPENAL)
  add_library( ll::openal INTERFACE IMPORTED )
  target_include_directories( ll::openal SYSTEM INTERFACE "${LIBS_PREBUILT_DIR}/include/AL")
  target_compile_definitions( ll::openal INTERFACE LL_OPENAL=1)
  use_prebuilt_binary(openal)

  if(WINDOWS)
    target_link_libraries( ll::openal INTERFACE
            OpenAL32
            alut
            )
  elseif(LINUX)
    target_link_libraries( ll::openal INTERFACE
            openal
            alut
            )
  else()
    target_link_libraries( ll::openal INTERFACE
            openal
            alut
            )
  endif()
endif ()
