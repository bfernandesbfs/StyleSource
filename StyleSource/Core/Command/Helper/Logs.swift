//
//  Logs.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation

public enum LogLevel {
    case info, warning, error
}

public enum ANSIColor: UInt8, CustomStringConvertible {
    case reset = 0

    case black = 30
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case `default`

    public var description: String {
        return "\u{001B}[\(self.rawValue)m"
    }

    func format(_ string: String) -> String {
        if let termType = getenv("TERM"), String(cString: termType).lowercased() != "dumb" &&
            isatty(fileno(stdout)) != 0 {
            return "\(self)\(string)\(ANSIColor.reset)"
        }
        else {
            return string
        }
    }
}

public func logMessage(_ level: LogLevel, _ string: CustomStringConvertible) {
    switch level {
    case .info:
        fputs(ANSIColor.green.format("\(string)\n"), stdout)
    case .warning:
        fputs(ANSIColor.yellow.format("Warning: \(string)\n"), stderr)
    case .error:
        fputs(ANSIColor.red.format("Error: \(string)\n"), stderr)
    }
}
