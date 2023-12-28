import Foundation

public func stableHash(_ str: String) -> UInt64 {
    var result = UInt64 (5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}

public func stableHash(data: Data) -> UInt64 {
    var result = UInt64 (5381)
    let buf = [UInt8](data)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}
