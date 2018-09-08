//
//  StyleParser.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/24/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Yams

public struct Style {
    var key: String
    var className: String
    var elements: [Element]
}

public struct Element {
    var key: String
    var value: Any
    var childs: [Element]

    subscript(_ key: String) -> Element? {
        return childs.filter { $0.key == key }.first
    }

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

public func styleParse(path: Path) throws -> [StyleModel] {

    let data: String = try path.read()

    guard var value = try Yams.load(yaml: data) as? Json else {
        throw Errors.yamlInvalid
    }

    value = value.filter { (key, value) -> Bool in
        guard let value = value as? Json else {
            return false
        }
        return value.contains { $0.key == "class" }
    }

    var styles: [Style] = []

    for (key, style) in value {

        guard let style = style as? Json else {
            continue
        }

        let isClass = style.contains { $0.key == "class" }

        if isClass, let className = style["class"] as? String {

            let data = style.filter { $0.key != "class" }

            let elements = findElement(data: data)

            let model = Style(key: key, className: className, elements: elements)
            styles.append(model)
        }
    }

    return []
}

public func findElement(data: Json) -> [Element] {

    var elements: [Element] = []
    for (key, value) in data {

        if let value = value as? Json {
            let childs = findElement(data: value)

            elements.append(Element(key: key, childs: childs))
        }
        else {
            elements.append(Element(key: key, value: value))
        }
    }

    return mergeElements(data: elements)
}

public func mergeElements(data: [Element]) -> [Element] {

    var elements: [Element] = []
    for element in data {
        if element.key == "style" {

            let sameRoot =  element.childs.filter { elm in data.contains { elm.key == $0.key } }

            for item in sameRoot {

                if let value = element[item.key] {
                    print(value.key)
                }
            }


            elements.append(contentsOf: element.childs)
        }
        else {
            elements.append(element)
        }
    }

    return elements
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

        return [:] //context
    }
}
