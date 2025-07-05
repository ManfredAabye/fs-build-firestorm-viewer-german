# -*- cmake -*-
include_guard()

include(Prebuilt)
use_prebuilt_binary(assimp)

add_library( fs::assimp INTERFACE IMPORTED )

if (WINDOWS)
  target_link_libraries( fs::assimp INTERFACE assimp-vc143-mt.lib )
elseif (DARWIN)
  target_link_libraries( fs::assimp INTERFACE libassimp.dylib )
elseif (LINUX)
  target_link_libraries( fs::assimp INTERFACE libassimp.a )
endif()

target_include_directories( fs::assimp SYSTEM INTERFACE
    ${AUTOBUILD_INSTALL_DIR}/include/assimp
)

