import Foundation
import Darwin
import CPTYFork

internal struct ForkReturn {
	fileprivate init(_ value: pid_t) {
		self.value = value
	}

	private var value: pid_t
	public var isParent: Bool { value > 0 }
	public var isChild: Bool { value == 0 }

	public var childProcessID: pid_t {
		precondition(isParent, "Cannot call childProcesID from the child process")
		return value
	}
}

internal func fork() -> ForkReturn {
	return ForkReturn(PTYKitPerformFork())
}

internal func forkpty() -> (result: ForkReturn, pty: FileHandle)? {
	var master: Int32 = 0
	let pid = Darwin.forkpty(&master, nil, nil, nil)
	if pid == -1 {
		return nil
	}

	return (ForkReturn(pid), FileHandle(fileDescriptor: master, closeOnDealloc: true))
}

internal func execve(processPath: String, arguments: [String], environment: [String] = []) -> Never {
	processPath.withCString { (pathPtr) in
		arguments.withCPointerToNullTerminatedArrayOfCStrings { (argvPtr) in
			environment.withCPointerToNullTerminatedArrayOfCStrings { (envPtr) in
				Darwin.execve(pathPtr, argvPtr, envPtr)
			}
		}
	}

	fatalError("execve() cannot return")
}
