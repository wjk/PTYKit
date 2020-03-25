#include "include/CPTYKitSupport.h"
#include <sys/wait.h>

pid_t PTYKitPerformFork(void) {
	return fork();
}

int PTYKitGetExitCodeFromWaitCode(int waitCode) {
	return WEXITSTATUS(waitCode);
}

int PTYKitDoesWaitCodeSpecifyNormalExit(int waitCode) {
	return WIFEXITED(waitCode);
}
