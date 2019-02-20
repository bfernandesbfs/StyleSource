//
//  ConfigEntry.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 9/23/18.
//  Copyright © 2018 bfs. All rights reserved.
//

import PathKit

internal class ConfigEntry {

    let template: TemplateType
    let structure: String
    let input: Path
    let output: Path
    let hash: String
    let required: Bool

    internal init(template: TemplateType, currentPath: Path, hash: String, data: Json) {

        guard let input = data["input"] as? String,
            let output = data["output"] as? Json,
            let structure = output["structure"] as? String,
            let path = output["path"] as? String else {
            fatalError("stylesource.yml - Please check documentation")
        }

        self.required = output["required"] as? Bool ?? true
        self.template = template
        self.structure = structure
        self.input = currentPath + Path(input)
        self.output = currentPath + Path(path)
        self.hash = hash
    }
}
