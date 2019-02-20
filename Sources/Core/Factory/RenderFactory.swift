//
//  RenderFactory.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Stencil

internal class RenderFactory {

    private let template: Path
    private let config: [ConfigEntry]

    internal init(template: Path, config: [ConfigEntry]) {
        self.template = template
        self.config = config
    }

    internal func build() throws {

        for entry in config {

            var context: [String: Any] = [:]

            switch entry.template {
            case .color:
                context = try ColorParser().transform(structure: entry.structure, required: entry.required, input: entry.input)
            case .font:
                context = try FontParser().transform(structure: entry.structure, required: entry.required, input: entry.input)
            case .style:
                context = try StyleParser().transform(structure: entry.structure, required: entry.required, input: entry.input)
            }

            FilterHelper.shared.add(type: entry.template, to: entry.structure)

            let rendered = try printTemplate(name: entry.template.name, context: context)
            try write(content: rendered, output: entry.output)
        }
    }

    private func printTemplate(name: String, context: [String: Any]) throws -> String {

        let fsLoader = FileSystemLoader(paths: [template])
        let environment = createEnvironment(loader: fsLoader)

        let rendered = try environment.renderTemplate(name: name, context: context)
        return rendered
    }

    private func write(content: String, output: Path) throws {
        try output.write(content)
        logMessage(.info, "File written: \(output)")
    }

    private func createEnvironment(loader: FileSystemLoader) -> Environment {
        let ext = Extension()
        ext.registerExtensions()

        return Environment(loader: loader, extensions: [ext], templateClass: StencilTemplate.self)
    }
}
