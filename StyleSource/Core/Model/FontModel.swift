//
//  FontModel.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation

internal struct FontData {
    var key: String
    var font: FontModel
}

internal struct FontModel: Codable {
    var name: String
    var family: String
    var path: String
}
