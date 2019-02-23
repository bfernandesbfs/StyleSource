//
//  TemplateType.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import PathKit

internal enum TemplateType: String, CaseIterable {
    case color, font, style

    var name: String {
        switch self {
        case .color: return "Template-Color.stencil"
        case .font: return "Template-Font.stencil"
        case .style: return "Template-Style.stencil"
        }
    }
}
