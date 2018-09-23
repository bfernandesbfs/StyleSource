//
//  Template.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit

public enum TemplateType: String {
    case font = "Template-Font.stencil"
    case color = "Template-Color.stencil"
    case style = "Template-Style.stencil"
    case none

    init(string: String) {
        guard let type = TemplateType(rawValue: string) else {
            self = .none
            return
        }
        self = type
    }

    var output: String {
        switch self {
        case .font:
            return "ThemeFont.swift"
        case .color:
            return "ThemeColor.swift"
        case .style:
            return "ThemeStyle.swift"
        default:
            return ""
        }
    }

    var input: String {
        switch self {
        case .font:
            return "ThemeFont.yaml"
        case .color:
            return "ThemeColor.yaml"
        case .style:
            return "ThemeStyle.yaml"
        default:
            return ""
        }
    }
}

internal struct Template {
    var type: TemplateType
    var name: String
    var path: Path

    internal init(name: String, path: Path) {
        self.name = name
        self.path = path
        self.type = TemplateType(string: name)
    }
}

extension Template: CustomStringConvertible {

    public var output: String {
        return type.output
    }

    public var description: String {
        return "\(name) - \(path.description)"
    }
}
