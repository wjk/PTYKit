import Foundation

internal extension Data {
	func asByteArray() -> [UInt8] {
		let basePtr = (self as NSData).bytes
		var array: [UInt8] = []

		for i in 0..<self.count {
			let ptr = basePtr.advanced(by: i)
			let byte = ptr.load(as: UInt8.self)
			array.append(byte)
		}

		return array
	}

	static func fromCStringAsCharacterArray(_ cCharacters:[CChar]) -> Data {
        precondition(cCharacters.count == 0 || cCharacters[(cCharacters.endIndex - 1)] == 0)
        var r = nil as Data?
        cCharacters.withUnsafeBufferPointer { (p:UnsafeBufferPointer<CChar>) -> () in
            let p1 = UnsafeRawPointer(p.baseAddress)!
            let opPtr = OpaquePointer(p1)
            r = Data(bytes: UnsafePointer<UInt8>(opPtr), count: p.count)
        }
        return r!
    }
}

internal extension Array where Element == String {
	func withCPointerToNullTerminatedArrayOfCStrings(_ block: @escaping (UnsafePointer<UnsafeMutablePointer<Int8>?>) -> Void) {
		// Keep this in memory until the block is be finished.
		let a: [NSMutableData] = self.map { (s:String) -> NSMutableData in
			let b = s.cString(using: String.Encoding.utf8)!
			assert(b[b.endIndex-1] == 0)
			return (Data.fromCStringAsCharacterArray(b) as NSData).mutableCopy() as! NSMutableData
		}

		let a1: [UnsafeMutablePointer<Int8>?] = a.map { (d:NSMutableData) -> UnsafeMutablePointer<Int8> in
			let opPtr = OpaquePointer(d.mutableBytes)
			return UnsafeMutablePointer<Int8>(opPtr)
		} + [nil]

		a1.withUnsafeBufferPointer { buffer -> Void in
			block(buffer.baseAddress!)
		}
	}
}
