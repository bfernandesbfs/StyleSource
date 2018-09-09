//
//  StencilTemplate.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/28/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import Stencil

public class StencilTemplate: Stencil.Template {

    public required init(templateString: String, environment: Environment? = nil, name: String? = nil) {
        let templateStringWithMarkedNewlines = templateString
            .replacingOccurrences(of: "\n\n", with: "\n\u{000b}\n")
            .replacingOccurrences(of: "\n\n", with: "\n\u{000b}\n")
        super.init(templateString: templateStringWithMarkedNewlines, environment: environment, name: name)
    }

    public override func render(_ dictionary: [String: Any]? = nil) throws -> String {
        return try removeExtraLines(from: super.render(dictionary))
    }

    private func removeExtraLines(from str: String) -> String {
        let extraLinesRE: NSRegularExpression = {
            do {
                return try NSRegularExpression(pattern: "\\n([ \\t]*\\n)+", options: [])
            }
            catch {
                fatalError("Regular Expression pattern error: \(error)")
            }
        }()
        let compact = extraLinesRE.stringByReplacingMatches(
            in: str,
            options: [],
            range: NSRange(location: 0, length: str.utf16.count),
            withTemplate: "\n"
        )
        let unmarkedNewlines = compact
            .replacingOccurrences(of: "\n\u{000b}\n", with: "\n\n")
            .replacingOccurrences(of: "\n\u{000b}\n", with: "\n\n")
        return unmarkedNewlines
    }
}

public extension Extension {

    typealias GenericFilter = (Any?, [Any?]) throws -> Any?

    public func registerExtensions() {
        registerStringsFilters()
    }

    private func registerFilter(_ name: String, filter: @escaping Filters.BooleanWithArguments) {

        registerFilter(name, filter: filter as GenericFilter)
        registerFilter("!\(name)", filter: { value, arguments in
            try !filter(value, arguments)
            } as GenericFilter)
    }

    private func registerStringsFilters() {
        registerFilter("hasPrefix", filter: Filters.Strings.hasPrefix)
        registerFilter("hasSuffix", filter: Filters.Strings.hasSuffix)
        registerFilter("removePrefix", filter: Filters.Strings.removePrefix)
        registerFilter("transform", filter: Filters.Strings.transform)
    }
}
