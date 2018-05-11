cmake_minimum_required(VERSION 3.5)
set(CMAKE_CXX_STANDARD 11)
aux_source_directory(. DIR_LIB_SRCS)
add_library(VFLib2 SHARED ${DIR_LIB_SRCS})