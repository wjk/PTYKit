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
    FileHandle.standardInput.readabilityHandler = { f in
        let d = f.availableData
        pty2.masterFileHandle.write(d)
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
    RunLoop.main.run()
    pty2.waitForChildProcessExit()
}
