import Foundation

@usableFromInline
let stableHashMask: UInt64 = 0x00ffffffffffffff

@usableFromInline
let stableHashSeed: UInt64 = 5381

@inlinable
public func stableHash(_ str: String) -> UInt64 {
    var result = stableHashSeed
    for b in str.utf8 {
        result = (result & stableHashMask) * 127 + UInt64(b)
    }
    return result
}

/// Hashes consecutive strings as though their UTF-8 bytes had first been joined.
@inlinable
public func stableHash<Strings: Sequence>(_ strings: Strings) -> UInt64 where Strings.Element == String {
    var result = stableHashSeed
    for string in strings {
        for byte in string.utf8 {
            result = (result & stableHashMask) * 127 + UInt64(byte)
        }
    }
    return result
}

@inlinable
public func stableHash(data: Data) -> UInt64 {
    var result = stableHashSeed
    data.withUnsafeBytes { raw in
        for b in raw {
            result = (result & stableHashMask) * 127 + UInt64(b)
        }
    }
    return result
}

@inlinable
public func stableHashHex(_ hash: UInt64) -> String {
    let hex = String(hash, radix: 16, uppercase: true)
    return hex.utf8.count >= 2 ? hex : "0" + hex
}
