import Foundation
import PTYKit

do {
	let arguments = [
		"slapconfig",
		"-createldapmasterandadmin",
		"--allow_local_realm",
		"diradmin",
		"Directory Administrator",
		"1024",
		"DC=sunsol,DC=internal",
		"SUNSOL.INTERNAL"
	]
	let pty2 = PTY(processPath: "/usr/sbin/slapconfig", arguments: arguments, environment: ["TERM=ansi"])!
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

	var stringAccumulator = ""
	pty2.masterFileHandle.readabilityHandler = { f in
		let d = f.availableData
		guard d.count > 0 else {
			if !stopRunLoop {
				print("end of file, exiting now")
			}

			stopRunLoop = true
			return
		}

		let s = String(data: d, encoding: .utf8)!
		stringAccumulator += s

		if stringAccumulator.hasSuffix("Password:") || stringAccumulator.hasSuffix("passphrase:") {
			pty2.masterFileHandle.write("password123\n")
			print("\(stringAccumulator) ••••••••", terminator: "")
		} else {
			print(s, terminator: "")
		}
	}

	while !stopRunLoop {
		RunLoop.main.run(mode: .default, before: Date.distantPast)
	}

	pty2.waitForChildProcessExit()
}
