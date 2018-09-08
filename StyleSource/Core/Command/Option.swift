//
//  Option.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/28/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

public enum Option: String {
    case input = "-i"
    case output = "-o"
    case unknown

    init(value: String) {
        switch value {
        case "-i": self = .input
        case "-o": self = .output
        default: self = .unknown
        }
    }
}
