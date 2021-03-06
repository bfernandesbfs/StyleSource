//
//  StyleModel.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/27/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation

internal struct StyleGroup {
    var name: String
    var cases: [String]
    var styles: [Style]
}

internal struct Style {
    var key: String
    var className: String
    var elements: [Element]
}

internal struct Element {
    var key: String
    var value: Any
    var childs: [Element]

    init(key: String, value: Any) {
        self.key = key
        self.value = value
        self.childs = []
    }

    init(key: String, childs: [Element]) {
        self.key = key
        self.value = NSNull()
        self.childs = childs
    }
}
