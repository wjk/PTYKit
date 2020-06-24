#pragma once
#include <unistd.h>

__BEGIN_DECLS
extern int PTYKitGetExitCodeFromWaitCode(int waitCode);
extern int PTYKitDoesWaitCodeSpecifyNormalExit(int waitCode); // returns 0 or 1
__END_DECLS
