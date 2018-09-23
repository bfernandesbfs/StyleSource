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

    guard let value = try Yams.load(yaml: data) as? Json,
        let colors = value[ConstantKeys.color] as? Json else {
            throw Errors.yamlInvalid
    }

    let list = colors.map { color -> ColorModel in
        let hex = color.value as? String ?? ""
        return ColorModel(key: color.key, hex: hex)
    }

    return list
}

internal class ColorParser {

    func transform(input: Path) throws -> [String: Any] {

        let data = try colorParse(path: input)

        let context = [ConstantKeys.color: data]

        return context
    }
}
