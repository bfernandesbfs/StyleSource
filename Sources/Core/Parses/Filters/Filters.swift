//
//  Filters.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/28/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import Stencil

internal enum Filters {

    internal enum Error: Swift.Error {
        case invalidInputType
    }

    internal static func parseString(from value: Any?) throws -> String {
        if let losslessString = value as? LosslessStringConvertible {
            return String(describing: losslessString)
        }
        if let string = value as? String {
            return string
        }
        throw Error.invalidInputType
    }
}

// MARK: - Strings Filters
internal extension Filters {

    enum Strings {

        internal static func reviseName(_ value: Any?) throws -> String {
            let string = try Filters.parseString(from: value)
            return string.replacingOccurrences(of: "UI", with: String()) + Keys.suffix
        }

        internal static func transform(_ value: Any?) throws -> [String] {
            guard let element = value as? Element else {
                throw Error.invalidInputType
            }

            return try FilterBuilder(element).build()
        }
    }
}
