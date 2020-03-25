#include "include/CPTYFork.h"

pid_t PTYKitPerformFork(void) {
	return fork();
}
