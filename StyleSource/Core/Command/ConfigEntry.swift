//
//  ConfigEntry.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 9/23/18.
//  Copyright © 2018 bfs. All rights reserved.
//

import PathKit

internal struct ConfigEntry {

    let template: TemplateType
    let structure: String
    let input: Path
    let output: Path
}

extension ConfigEntry {

    internal init(template: TemplateType, currentPath: Path, data: Json) throws {

        guard let structure = data["structure"] as? String,
            let input = data["input"] as? String,
            let output = data["output"] as? String else {
            throw Errors.yamlInvalid(path: "stylesource.yml - Please check documentation")
        }

        self.template = template
        self.structure = structure
        self.input = currentPath + Path(input)
        self.output = currentPath + Path(output)
    }
}
