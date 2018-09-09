//
//  StyleParser.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/24/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Yams

public struct StyleGroup {
    var name: String
    var cases: [String]
    var styles: [Style]
}

public struct Style {
    var key: String
    var className: String
    var elements: [Element]
}

public struct Element {
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

public func styleParse(path: Path) throws -> [StyleGroup] {

    let data: String = try path.read()

    guard let value = try Yams.load(yaml: data) as? Json else {
        throw Errors.yamlInvalid
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

    var groups: [StyleGroup] = []
    for name in Set(styles.map { $0.className }) {

        let stys = styles.filter { $0.className == name }
        let cases = stys.map { $0.key }

        groups.append(StyleGroup(name: name,
                                 cases: cases,
                                 styles: stys))
    }

    return groups
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

    return removeLevelElements(data: elements)
}

public func removeLevelElements(data: [Element]) -> [Element] {

    var elements: [Element] = []
    for element in data {
        if element.key == "style" {
            elements.append(contentsOf: element.childs)
        }
        else {
            elements.append(element)
        }
    }

    return elements
}

public class StyleParser {

    func transform(input: Path) throws -> [String: Any] {

        let data = try styleParse(path: input)

        let context = [
            ConstantKeys.group: data
        ]

        return context
    }
}
