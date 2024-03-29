cmake_minimum_required(VERSION 3.16.0)

project(transport_native C ASM)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(include)
include_directories(${EXECUTOR_INCLUDE_DIRECTORY})
include_directories(${CORE_INCLUDE_DIRECTORY})
include_directories(${MEMORY_INCLUDE_DIRECTORY})

file(GLOB sources
  **/*.c
  **/*.h
)

add_library(transport_debug_linux_x64 SHARED ${sources})
add_dependencies(transport_debug_linux_x64 executor_debug_linux_x64)
target_link_libraries(transport_debug_linux_x64 PRIVATE ${EXECUTOR_LIBRARY})
set_target_properties(transport_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG})
copy_to_assets(transport_debug_linux_x64)

add_library(transport_release_linux_x64 SHARED ${sources})
add_dependencies(transport_release_linux_x64 executor_release_linux_x64)
target_link_libraries(transport_release_linux_x64 PRIVATE ${EXECUTOR_LIBRARY})
set_target_properties(transport_release_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE})
copy_to_assets(transport_release_linux_x64)

add_custom_target(transport_native DEPENDS "transport_release_linux_x64;transport_debug_linux_x64")