//
//  StyleParser.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/24/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Yams

public func styleParse(path: Path) throws -> [StyleModel] {

    let data: String = try path.read()

    guard let value = try Yams.load(yaml: data) as? Json,
        let style = value[ConstantKeys.style] as? Json else {
            throw Errors.yamlInvalid
    }

    return discoverRoots(style)
}

public func discoverRoots(_ root: Json) -> [StyleModel] {

    var model: [StyleModel] = []

    for (key, value) in root {

        if let data = value as? Json {
            let elements = discoverElement(data: data)
            model.append(StyleModel(key: key,
                                    className: elements.1,
                                    elements: elements.0,
                                    cases: (elements.0.map { $0.key })))
        }
    }

    return model
}

public func discoverElement(data: Json) -> ([StyleElement], String) {

    var elements: [StyleElement] = []
    guard let className = data["class"] as? String else {
        fatalError("missing class property")
    }

    for (key, value) in data {

        if let item = value as? Json {
            let values = discoverValues(item: item)
            elements.append(StyleElement(key: key, styles: values))
        }
    }

    return (elements, className)
}

public func discoverValues(item: Json) -> [StyleValue] {

    var values: [StyleValue] = []

    for (key, value) in item {
        values.append(StyleValue(name: key, data: value))
    }

    return values
}

public class StyleParser {

    func transform(input: Path) throws -> [String: Any] {

        let data = try styleParse(path: input)

        let context = [
            ConstantKeys.style: data
        ]

        return context
    }
}
