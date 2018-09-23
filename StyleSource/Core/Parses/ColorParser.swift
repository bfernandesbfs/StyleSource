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
        throw Errors.yamlInvalid
    }

    let list = colors.map { color -> ColorModel in
        let hex = color.value as? String ?? ""
        return ColorModel(key: color.key, hex: hex)
    }

    return list
}

internal class ColorParser {

    func transform(structure: String, input: Path) throws -> [String: Any] {

        let data = try colorParse(path: input)

        let context = [ConstantKeys.group: ColorGroup(structure: structure, colors: data)]

        return context
    }
}
