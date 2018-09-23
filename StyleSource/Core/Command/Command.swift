//
//  Command.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import PathKit
import Yams

internal class Command {

    private let loader: LoaderTemplates

    internal init() {
        loader = LoaderTemplates(bundle: Bundle.main)
    }

    internal func staticMode() {

        do {
            let entry = try checkEntry(file: Path("/Users/bruno/Desktop/stylesource.yml"))
            let render = RenderFactory(template: try loader.fixture(), config: entry)
            try render.build()

        } catch let error as Errors {
            logMessage(.error, error.description)
        } catch {
            logMessage(.error, "\(error) - \(error.localizedDescription)")
        }
    }

    private func checkEntry(file: Path) throws -> [ConfigEntry] {

        if !file.exists {
            throw Errors.pathNotFound
        }

        let content: String = try file.read()

        guard let anyConfig = try Yams.load(yaml: content) as? Json else {
            throw Errors.yamlInvalid
        }

        var setup: [ConfigEntry] = []

        for type in TemplateType.allCases {

            if let config = anyConfig[type.rawValue] as? Json {

                let config = try ConfigEntry(template: type, data: config)
                setup.append(config)
            }
        }

        return setup
    }
}
