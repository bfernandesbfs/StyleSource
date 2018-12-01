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
            let entry = try checkEntry()
            let render = RenderFactory(template: try loader.fixture(), config: entry)
            try render.build()

        } catch let error as Errors {
            logMessage(.error, error.description)
        } catch {
            logMessage(.error, "\(error) - \(error.localizedDescription)")
        }
    }

    private func checkEntry() throws -> [ConfigEntry] {

        let currentPath = Path(FileManager.default.currentDirectoryPath)

        let file = currentPath + Path("stylesource.yml")

        if !file.exists {
            throw Errors.configEntryNotFound
        }

        let content: String = try file.read()

        guard let anyConfig = try Yams.load(yaml: content) as? Json else {
            throw Errors.yamlInvalid(path: "stylesource.yml")
        }

        var setup: [ConfigEntry] = []

        for type in TemplateType.allCases {

            if let items = anyConfig[type.rawValue] as? [Json] {

                let config = items.map { ConfigEntry(template: type, currentPath: currentPath, data: $0) }

                setup.append(contentsOf: config)
            }
        }

        return setup
    }
}
