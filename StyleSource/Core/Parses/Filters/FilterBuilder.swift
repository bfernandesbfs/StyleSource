//
//  FilterBuilder.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 9/9/18.
//  Copyright © 2018 bfs. All rights reserved.
//

import Foundation

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

        return "Palette.\(string)"
    }

    private func transformToFont(_ values: [Element]) throws -> String {

        let font = values.map({ elm -> String in
            if elm.key == "name" {
                return "Font.\(elm.value)"
            } else if elm.key == "size" {
                return ".font(size: \(elm.value))"
            }
            return String()
        })

        return "\(prefix)\(element.key), setTo: \(font.joined()))"
    }

    private func transformToLayer(_ values: [Element]) throws -> [String] {

        let layers = values.map { elm -> String in

            do {
                if elm.key == "borderColor" {
                    let value = try transformToColor(elm.value)
                    return "\(prefix)\(element.key).\(elm.key), setTo: \(value).cgColor)"
                } else {
                    return "\(prefix)\(element.key).\(elm.key), setTo: \(elm.value))"
                }
            } catch {
                return String()
            }
        }

        return layers
    }
}
