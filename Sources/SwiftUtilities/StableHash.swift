import Foundation

@inlinable
public func stableHash(_ str: String) -> UInt64 {
    let mask: UInt64 = 0x00ffffffffffffff
    var result: UInt64 = 5381
    for b in str.utf8 {
        result = (result & mask) * 127 + UInt64(b)
    }
    return result
}

@inlinable
public func stableHash(data: Data) -> UInt64 {
    let mask: UInt64 = 0x00ffffffffffffff
    var result: UInt64 = 5381
    data.withUnsafeBytes { raw in
        for b in raw {
            result = (result & mask) * 127 + UInt64(b)
        }
    }
    return result
}
