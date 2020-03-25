import XCTest
@testable import PTYKit

@available(OSX 10.15, *)
final class PTYKitTests: XCTestCase {
    func testCat() {
		guard let pty = PTY(processPath: "/bin/cat", arguments: ["/bin/cat"]) else {
			XCTFail("Could not create PTY object")
			return
		}

		var output = ""
		let sema = DispatchSemaphore(value: 0)
		pty.masterFileHandle.readInBackground(qualityOfService: .default) { (data) in
			if let data = data {
				output += String(data: data, encoding: .utf8)!
				sema.signal()
			}
		}

		pty.masterFileHandle.write("Hello, World!\n")
		sema.wait()

		try! pty.masterFileHandle.close()
		pty.waitForChildProcessExit()

		XCTAssertEqual(output, "Hello, World!\r\n")
    }

    static var allTests = [
        ("testCat", testCat),
    ]
}
