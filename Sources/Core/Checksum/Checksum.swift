//
//  Checksum.swift
//  CYaml
//
//  Created by luiz.fernando.silva on 20/02/2019.
//

import Cocoa
import CryptoSwift

func hashFileContents(atPath path: String) throws -> String {
    let contents = try String(contentsOfFile: path)

    return checksum(string: contents)
}

func checksum(string: String) -> String {
    let hash: [UInt8] = string.utf8CString.withUnsafeBytes { pointer -> [UInt8] in
        let chars = pointer.bindMemory(to: UInt8.self)

        return SHA2(variant: .sha256).calculate(for: Array(chars))
    }

    return hash.map { String(format: "%0x", $0).uppercased() }.joined()
}
