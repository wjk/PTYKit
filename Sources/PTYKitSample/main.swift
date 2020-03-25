import Foundation
import PTYKit

do {
	/// Basic usage.
	let p = PTY(processPath: "/bin/ls", arguments: ["/bin/ls", "-Gbla"], environment: ["TERM=ansi"])!
	print(String(data: p.masterFileHandle.readDataToEndOfFile(), encoding: .utf8) ?? "<null>")
	p.waitForChildProcessExit()
}

do {
	///
	/// This runs infinite REPL loop.
	/// You can test this program with Xcode console.
	///
	let pty2 = PTY(processPath: "/bin/zsh", arguments: ["/bin/zsh"], environment: ["TERM=ansi"])!
	var stopRunLoop = false
	FileHandle.standardInput.readabilityHandler = { f in
		let d = f.availableData
		if d.count > 0 {
			pty2.masterFileHandle.write(d)
		} else {
			guard #available(macOS 10.15, *) else {
				fatalError("can only run on macOS 10.15 or later")
			}

			try! pty2.masterFileHandle.close()
			stopRunLoop = true
		}
	}
	pty2.masterFileHandle.readabilityHandler = { f in
		let d = f.availableData
		guard d.count > 0 else {
			print("end of file, exiting now")
			exit(0)
		}

		let s = String(data: d, encoding: .utf8)!
		print(s)
	}

	while !stopRunLoop {
		RunLoop.main.run(mode: .default, before: Date.distantPast)
	}

	pty2.waitForChildProcessExit()
}
