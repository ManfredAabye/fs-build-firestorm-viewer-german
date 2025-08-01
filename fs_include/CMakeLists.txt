# -*- cmake -*-

include(00-Common)

project(cmake)

set(cmake_SOURCE_FILES
        CMakeLists.txt
        00-Common.cmake
        APR.cmake
        Assimp.cmake
        Audio.cmake
        Boost.cmake
        bugsplat.cmake
        BuildVersion.cmake
        CEFPlugin.cmake
        CMakeCopyIfDifferent.cmake
        ConfigurePkgConfig.cmake
        CURL.cmake
        Copy3rdPartyLibs.cmake
        DBusGlib.cmake
        DeploySharedLibs.cmake
        Discord.cmake # <FS:LO> Discord rich presence
        DragDrop.cmake
        EXPAT.cmake
        FindAutobuild.cmake
        FMODSTUDIO.cmake
        FreeType.cmake
        GLEXT.cmake
        GLH.cmake
        GLM.cmake
        GLOD.cmake # <FS:Ansariel> Bring back GLOD
        Havok.cmake
        Hunspell.cmake
        LLAddBuildTest.cmake
        LLAppearance.cmake
        LLAudio.cmake
        LLCommon.cmake
        LLImage.cmake
        LLKDU.cmake
        LLPhysicsExtensions.cmake
        LLPrimitive.cmake
        LLSharedLibs.cmake
        LLTestCommand.cmake
        LLWindow.cmake
        Linking.cmake
        MediaPluginBase.cmake    # <FS:Zi> Linux volume catcher
        Meshoptimizer.cmake
        NDOF.cmake
        OPENAL.cmake
        OpenGL.cmake
        OpenJPEG.cmake
        OpenSSL.cmake
        PNG.cmake
        PluginAPI.cmake
        Prebuilt.cmake
        PulseAudio.cmake
        Python.cmake
        TemplateCheck.cmake
        TinyEXR.cmake
        TinyGLTF.cmake
        Tut.cmake
        UI.cmake
        UnixInstall.cmake
        Variables.cmake
        ViewerMiscLibs.cmake
        VisualLeakDetector.cmake
        LibVLCPlugin.cmake
        WebRTC.cmake
        xxHash.cmake
        ZLIBNG.cmake
        )

source_group("Shared Rules" FILES ${cmake_SOURCE_FILES})

set(master_SOURCE_FILES
        ../CMakeLists.txt
        )

source_group("Master Rules" FILES ${master_SOURCE_FILES})

add_library(cmake
        cmake_dummy.cpp
        ${cmake_SOURCE_FILES}
        ${master_SOURCE_FILES}
        )
