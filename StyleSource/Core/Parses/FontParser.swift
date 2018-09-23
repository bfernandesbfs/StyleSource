//
//  FontParser.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import PathKit
import Yams

private func fontParse(path: Path) throws -> [FontData] {

    var list: [FontData] = []

    let data: String = try path.read()

    guard let value = try Yams.load(yaml: data) as? Json,
        let fonts = value[ConstantKeys.font] as? [Json] else {
            throw Errors.yamlInvalid
    }

    for font in fonts {
        for (key, value) in font {

            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)

            let decoder = JSONDecoder()
            let model = try decoder.decode(FontModel.self, from: data)

            list.append(FontData(key: key, font: model))
        }
    }

    return list
}

internal class FontParser {

    func transform(structure: String, input: Path) throws -> [String: Any] {

        let data = try fontParse(path: input)

        let context = [ConstantKeys.group: FontGroup(structure: structure, fonts: data)]

        return context
    }
}
