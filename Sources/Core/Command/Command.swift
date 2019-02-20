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

public class Command {

    private let loader: LoaderTemplates

    public init() {
        loader = LoaderTemplates(bundle: Bundle.main)
    }

    public func staticMode() {

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

    internal func checkEntry() throws -> [ConfigEntry] {

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
            guard let items = anyConfig[type.rawValue] as? [Json] else {
                continue
            }

            let configs = try makeEntries(from: items, currentPath: currentPath, templateType: type)
            setup.append(contentsOf: configs)
        }

        return setup
    }

    internal func makeEntries(from list: [Json], currentPath: Path, templateType: TemplateType) throws -> [ConfigEntry] {
        var configs: [ConfigEntry] = []

        for item in list {
            guard let inputName = item["input"] as? String else {
                fatalError("stylesource.yml - Please check documentation")
            }
            guard let output = item["output"] as? Json, let outputName = output["path"] as? String else {
                fatalError("stylesource.yml - Please check documentation")
            }
            guard let structure = output["structure"] as? String else {
                fatalError("stylesource.yml - Please check documentation")
            }

            let inputPath = currentPath + Path(inputName)
            let outputPath = currentPath + Path(outputName)
            let hash = try hashFileContents(atPath: inputPath.normalize().string)

            if try matchesHash(generatedSwiftPath: outputPath, structureName: structure, hash: hash) {
                continue
            }

            configs.append(ConfigEntry(template: templateType, currentPath: currentPath, hash: hash, data: item))
        }

        return configs
    }

    internal func matchesHash(generatedSwiftPath: Path, structureName: String, hash: String) throws -> Bool {
        if !generatedSwiftPath.exists {
            return false
        }

        let contents = try generatedSwiftPath.read(.utf8)

        let lines = contents.split(separator: "\n", maxSplits: 3)
        if lines.count < 2 {
            return false
        }

        let splitLine = lines[1].split(separator: ":")
        if splitLine.count != 3 {
            return false
        }

        return splitLine[0] == structureName && splitLine[1] == hash
    }
}
