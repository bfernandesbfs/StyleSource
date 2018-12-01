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

    internal init(template: TemplateType, currentPath: Path, data: Json) {

        guard let input = data["input"] as? String,
            let output = data["output"] as? Json,
            let structure = output["structure"] as? String,
            let path = output["path"] as? String else {
            fatalError("stylesource.yml - Please check documentation")
        }

        self.template = template
        self.structure = structure
        self.input = currentPath + Path(input)
        self.output = currentPath + Path(path)
    }
}
