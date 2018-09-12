//
//  Filters.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/28/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import Stencil

public enum Filters {

    typealias BooleanWithArguments = (Any?, [Any?]) throws -> Bool

    public enum Error: Swift.Error {
        case invalidInputType
    }

    public static func parseString(from value: Any?) throws -> String {
        if let losslessString = value as? LosslessStringConvertible {
            return String(describing: losslessString)
        }
        if let string = value as? String {
            return string
        }
        throw Error.invalidInputType
    }

    public static func parseStringArgument(from arguments: [Any?], at index: Int = 0) throws -> String {
        guard index < arguments.count else {
            throw Error.invalidInputType
        }
        if let losslessString = arguments[index] as? LosslessStringConvertible {
            return String(describing: losslessString)
        }
        if let string = arguments[index] as? String {
            return string
        }
        throw Error.invalidInputType
    }
}

// MARK: - Strings Filters
public extension Filters {

    enum Strings {

        public static func contains(_ value: Any?, arguments: [Any?]) throws -> Bool {
            let string = try Filters.parseString(from: value)
            let substring = try Filters.parseStringArgument(from: arguments)
            return string.contains(substring)
        }

        public static func hasPrefix(_ value: Any?, arguments: [Any?]) throws -> Bool {
            let string = try Filters.parseString(from: value)
            let prefix = try Filters.parseStringArgument(from: arguments)
            return string.lowercased().hasPrefix(prefix)
        }

        public static func hasSuffix(_ value: Any?, arguments: [Any?]) throws -> Bool {
            let string = try Filters.parseString(from: value)
            let suffix = try Filters.parseStringArgument(from: arguments)
            return string.lowercased().hasSuffix(suffix)
        }

        public static func reviseName(_ value: Any?) throws -> String {
            let string = try Filters.parseString(from: value)
            return string.replacingOccurrences(of: "UI", with: String()) + ConstantKeys.suffix
        }

        public static func transform(_ value: Any?) throws -> [String] {
            guard let element = value as? Element else {
                throw Error.invalidInputType
            }

            return try FilterBuilder(element).build()
        }
    }
}
