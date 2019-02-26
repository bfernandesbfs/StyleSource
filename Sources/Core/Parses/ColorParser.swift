//
//  ColorParser.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/24/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Yams

private func colorParse(path: Path) throws -> [ColorModel] {

    let data: String = try path.read()

    guard let colors = try Yams.load(yaml: data) as? Json else {
        throw Errors.yamlInvalid(path: "\(path) load error")
    }

    let list = colors.map { color -> ColorModel in
        let hex = color.value as? String ?? ""
        return ColorModel(key: color.key, hex: hex)
    }

    return list
}

internal class ColorParser {

    func transform(hash: String, structure: String, required: Bool, input: Path) throws -> [String: Any] {

        let data = try colorParse(path: input)

        let context: [String: Any] = [
            Keys.hash: hash,
            Keys.group: data,
            Keys.structure: structure,
            Keys.core: required,
        ]

        return context
    }
}
