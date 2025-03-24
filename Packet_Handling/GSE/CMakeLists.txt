cmake_minimum_required(VERSION 3.10.0)
project(GSE_serialise VERSION 0.1.0 LANGUAGES C CXX)

include_directories(~/.include/cpp/**)


add_library(GSE_serialise GSE_serialise.cpp)
target_include_directories(GSE_serialise PRIVATE include)


include(CTest)
enable_testing()

