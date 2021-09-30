cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(fsbackup_service VERSION 1.0.0 LANGUAGES C)
add_library(fsbackup_service SHARED Service.c Service.def)
#add_executable(fsbackup_service Service.c)

set_target_properties(fsbackup_service PROPERTIES
    PUBLIC_HEADER Service.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "fsbackup_service"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
#to build and compile use 
#cmake -G "Visual Studio 15 2017 Win64"
#msbuild /p:Configuration=Release fsbackup_service.sln