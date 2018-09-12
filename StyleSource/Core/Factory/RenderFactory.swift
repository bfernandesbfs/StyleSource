//
//  RenderFactory.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit
import Stencil

public class RenderFactory {

    private let templates: [Template]
    private let config: Config

    public init(templates: [Template], config: Config) {
        self.templates = templates
        self.config = config
    }

    public func build() throws {

        for template in templates {

            guard let input = config[.input], let output = config[.output] else {
                throw Errors.pathNotFound
            }

            let inputPath = input + Path(template.type.input)
            let outputPath = output + Path(template.output)

            if inputPath.exists {

                var context: [String: Any] = [:]

                switch template.type {
                case .font:
                    context = try FontParser().transform(input: inputPath)
                case .color:
                    context = try ColorParser().transform(input: inputPath)
                case .style:
                    context = try StyleParser().transform(input: inputPath)
                default:
                    logMessage(.warning, "Template type not font")
                }

                let rendered = try printTemplate(template: template, context: context)
                try write(content: rendered, output: outputPath)
            }
            else {
                logMessage(.warning, "\(template.type.input) not found")
            }
        }
    }

    private func printTemplate(template: Template, context: [String: Any]) throws -> String {

        let fsLoader = FileSystemLoader(paths: [template.path])
        let environment = createEnvironment(loader: fsLoader)

        let rendered = try environment.renderTemplate(name: template.name, context: context)
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
