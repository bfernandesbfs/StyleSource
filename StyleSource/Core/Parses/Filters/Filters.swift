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

    /// Parses filter input value for a string value, where accepted objects must conform to
    /// `CustomStringConvertible`
    ///
    /// - Parameters:
    ///   - value: an input value, may be nil
    /// - Throws: Filters.Error.invalidInputType
    public static func parseString(from value: Any?) throws -> String {
        if let losslessString = value as? LosslessStringConvertible {
            return String(describing: losslessString)
        }
        if let string = value as? String {
            return string
        }
        throw Error.invalidInputType
    }

    /// Parses filter arguments for a string value, where accepted objects must conform to
    /// `CustomStringConvertible`
    ///
    /// - Parameters:
    ///   - arguments: an array of argument values, may be empty
    ///   - index: the index in the arguments array
    /// - Throws: Filters.Error.invalidInputType
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

        public static func transform(_ value: Any?) throws -> [StyleValue]? {
            guard let dict = value as? [String: Any] else {
                return nil
            }

            var values: [StyleValue] = []
            for (key, value) in dict {
                values.append(StyleValue(name: key, data: value))
            }
            return values
        }

        public static func inset(_ value: Any?) throws -> String? {
            guard let dict = value as? [String: Any] else {
                return nil
            }

            return "UIEdgeInsets(top: \(dict["top"]!), left: \(dict["left"]!), bottom: \(dict["bottom"]!), right: \(dict["right"]!))"
        }

        public static func colors(_ value: Any?) throws -> String? {
            let string = try Filters.parseString(from: value)

            if string.hasPrefix("UI") || string.hasPrefix(".") {
                return string
            }

            return "ThemeColor.\(string)"
        }
    }
}
