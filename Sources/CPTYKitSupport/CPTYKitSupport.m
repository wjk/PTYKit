#include "include/CPTYKitSupport.h"
#include <sys/wait.h>

int PTYKitGetExitCodeFromWaitCode(int waitCode) {
	return WEXITSTATUS(waitCode);
}

int PTYKitDoesWaitCodeSpecifyNormalExit(int waitCode) {
	return WIFEXITED(waitCode);
}
