#ifndef STORAGE_LAUNCHER_H
#define STORAGE_LAUNCHER_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_LEAF_FUNCTION void storage_launcher_launch(char* binary_path);
DART_LEAF_FUNCTION void storage_launcher_shutdown(int32_t code);

#if defined(__cplusplus)
}
#endif

#endif