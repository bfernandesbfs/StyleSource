//
//  Errors.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

public enum Errors: Error, CustomStringConvertible {

    case argsInvalid, pathNotFound, templateNotFound(path: String), yamlInvalid

    public var description: String {
        switch self {
        case .argsInvalid:
            return "Args invalid"
        case .pathNotFound:
            return "Path not found"
        case .templateNotFound(let path):
            return "Template not found - \(path)"
        case .yamlInvalid:
            return "Yaml invalid"
        }
    }
}
