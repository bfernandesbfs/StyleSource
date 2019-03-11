//
//  Arguments.swift
//  CYaml
//
//  Created by luiz.fernando.silva on 11/03/2019.
//

public struct ArgumentKeys {
    public static var alwaysOverwrite = "--always-overwrite"
}

public struct Arguments {
    public static var `default` = Arguments(alwaysOverride: false)

    public var alwaysOverride: Bool

    public static func parse(from arguments: [String]) throws -> Arguments {
        var output = Arguments(alwaysOverride: false)

        for argument in arguments {
            switch argument {
            case ArgumentKeys.alwaysOverwrite:
                output.alwaysOverride = true

            default:
                throw ParseError.unknownArgument(argument)
            }
        }

        return output
    }

    public enum ParseError: Error {
        case unknownArgument(String)

        public var localizedDescription: String {
            return description
        }

        var description: String {
            switch self {
            case .unknownArgument(let name):
                return "Unknown command line argument: \(name)"
            }
        }
    }
}
