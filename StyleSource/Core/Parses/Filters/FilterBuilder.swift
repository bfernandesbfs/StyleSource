//
//  FilterBuilder.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 9/9/18.
//  Copyright © 2018 bfs. All rights reserved.
//

import Foundation

internal class FilterHelper {

    internal static let shared: FilterHelper = FilterHelper()

    private var storage: [TemplateType: String] = [:]

    internal subscript (type: TemplateType) -> String {
        return storage[type] ?? String()
    }

    internal func add(type: TemplateType, to name: String) {

        if storage[type] == nil {
            storage[type] = name
        }
    }
}

internal class FilterBuilder {

    private let element: Element
    private let prefix: String

    init(_ element: Element, prefix: String = String()) {
        self.element = element
        self.prefix = ".with(\\.\(prefix)"
    }

    internal func build() throws -> [String] {

        if element.childs.isEmpty {
            if element.key.lowercased().hasSuffix("color") {
                let value = try transformToColor(element.value)
                return ["\(prefix)\(element.key), setTo: \(value))"]
            }
            return ["\(prefix)\(element.key), setTo: \(element.value))"]
        } else {

            if element.key.hasSuffix("font") {

                let value = try transformToFont(element.childs)
                return [value]

            } else if element.key.lowercased().hasSuffix("layer") {

                let value = try transformToLayer(element.childs)
                return value
            } else if element.key.lowercased().hasSuffix("titlelabel") {

                let prefix = element.key + "!."
                let styles = element.childs.flatMap { elm -> [String] in
                    do {
                        return try FilterBuilder(elm, prefix: prefix).build()
                    } catch {
                        return []
                    }
                }
                return styles
            }
        }

        return []
    }

    private func transformToColor(_ value: Any?) throws -> String {
        let string = try Filters.parseString(from: value)

        if string.hasPrefix("UI") || string.hasPrefix(".") {
            return string
        }

        return "\(string)"
    }

    private func transformToFont(_ values: [Element]) throws -> String {

        var font: [String] = []

        for item in values {
            if item.key == "name" {
                let structure = FilterHelper.shared[.font]
                font.insert("\(structure).\(item.value)", at: 0)
            } else if item.key == "size" {
                font.append(".font(size: \(item.value))")
            }
        }

        return "\(prefix)\(element.key), setTo: \(font.joined()))"
    }

    private func transformToLayer(_ values: [Element]) throws -> [String] {

        var layers: [String] = []

        for item in values {
            if item.key.lowercased().hasSuffix("Color") {
                let value = try transformToColor(item.value)
                layers.append("\(prefix)\(element.key).\(item.key), setTo: \(value).cgColor)")
            } else {
                layers.append("\(prefix)\(element.key).\(item.key), setTo: \(item.value))")
            }
        }

        return layers
    }
}
