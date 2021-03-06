import Foundation
import CPTYKitSupport

public struct PTY {
	public let masterFileHandle: FileHandle
	public let childProcessID: pid_t

	public init?(processPath: String, arguments: [String], environment: [String] = []) {
		precondition(arguments.count >= 1, "arguments[0] must exist")
		precondition(processPath.hasSuffix(arguments[0]), "arguments[0] must be filename of process")

		if let (forkResult, masterFD) = forkpty() {
			if forkResult.isParent {
				masterFileHandle = FileHandle(fileDescriptor: masterFD, closeOnDealloc: true)
				childProcessID = forkResult.childProcessID
			} else {
				execve(processPath: processPath, arguments: arguments, environment: environment)
			}
		} else {
			// These two lines prevent the compiler from complaining.
			masterFileHandle = FileHandle()
			childProcessID = 0
			return nil
		}
	}

	@discardableResult
	public func waitForChildProcessExit() -> Int? {
		var waitCode: Int32 = 0
		_ = waitpid(childProcessID, &waitCode, 0)

		if PTYKitDoesWaitCodeSpecifyNormalExit(waitCode) != 0 {
			return Int(PTYKitGetExitCodeFromWaitCode(waitCode))
		} else {
			return nil
		}
	}
}

// MARK: -

public extension FileHandle {
	func write(_ text: String, encoding: String.Encoding = .utf8) {
		guard let data = text.data(using: encoding) else {
			preconditionFailure("String contents not expressible in requested encoding")
		}

		self.write(data)
	}

	// When the callback is called with a nil parameter, that is the EOF signal.
	@available(OSX 10.12, *)
	func readInBackground(qualityOfService: QualityOfService, _ block: @escaping (Data?) -> Void) {
		let thread = Thread {
			let observer1 = NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification, object: self, queue: OperationQueue.current) { (notification: Notification) in
				let data = notification.userInfo![NSFileHandleNotificationDataItem] as! Data
				block(data)

				self.readInBackgroundAndNotify()
			}
			var observer2 = observer1 // needed to avoid a compiler error
			observer2 = NotificationCenter.default.addObserver(forName: Notification.Name.NSFileHandleReadToEndOfFileCompletion, object: self, queue: OperationQueue.current) { (notification: Notification) in
				NotificationCenter.default.removeObserver(observer1)
				NotificationCenter.default.removeObserver(observer2)

				block(nil)
				Thread.exit()
			}

			self.readInBackgroundAndNotify()
			RunLoop.current.run()
		}

		thread.qualityOfService = qualityOfService
		thread.start()
	}
}
