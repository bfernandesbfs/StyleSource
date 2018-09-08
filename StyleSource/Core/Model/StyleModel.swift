//
//  StyleModel.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/27/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation

public struct StyleModel {
    var key: String
    var className: String
    var elements: [StyleElement]
    var cases: [String]
}

public struct StyleElement {
    var key: String
    var styles: [StyleValue]
}

public struct StyleValue {
    var name: String
    var data: Any
}
