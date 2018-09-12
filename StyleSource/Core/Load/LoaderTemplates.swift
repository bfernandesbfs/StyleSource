//
//  LoaderTemplates.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import PathKit

public class LoaderTemplates {

    private let bundle: Bundle
    private let fileManager: FileManager

    public init(bundle: Bundle) {
        self.bundle = bundle
        self.fileManager = FileManager.default
    }

    public func fixture() throws -> [Template] {

        let path = try resolvePath()

        let items = try fileManager.contentsOfDirectory(atPath: path.description)

        if items.isEmpty {
            throw Errors.templateNotFound("Stencil")
        }

        var list: [Template] = []
        for item in items where item.hasSuffix(".stencil") {
            list.append(Template(name: item, path: path))
        }

        return list
    }

    private func resolvePath() throws -> Path {

        guard let applicationPath = bundle.resourcePath else {
            throw Errors.templateNotFound("Application")
        }

        if let path = bundle.object(forInfoDictionaryKey: "TemplatePath") as? String, !path.isEmpty {
            return Path(applicationPath) + Path(path)
        }
        else if let path = bundle.path(forResource: "templates", ofType: nil) {
            return Path(path)
        }

        throw Errors.templateNotFound("Invalid")
    }
}
