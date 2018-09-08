//
//  Command.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 6/23/18.
//  Copyright © 2018 Bruno Fernandes. All rights reserved.
//

import Foundation
import PathKit

public class Command {

    private let loader: LoaderTemplates

    public init() {
        loader = LoaderTemplates(bundle: Bundle.main)
    }

    public func staticMode() {

        let info: ProcessInfo = ProcessInfo.processInfo
        if info.arguments.count >= 2 {
            let args = Array(info.arguments.dropFirst())

            do {

                guard args.indices.contains(0) else {
                    throw Errors.pathNotFound
                }

                let config = try self.check(args: args)
                let render = RenderFactory(templates: try loader.fixture(), config: config)
                try render.build()

            }
            catch let error as Errors {
                logMessage(.error, error.description)
            }
            catch {
                logMessage(.error, "\(error) - \(error.localizedDescription)")
            }
        }
        else {
            logMessage(.info, Errors.argsInvalid.description)
        }
    }

    private func getOption(_ option: String) -> Option {
        return Option(value: option)
    }

    private func check(args:[String]) throws -> Config {

        if args.count >= 4 {

            var config: Config = [:]

            for index in 0..<2 {

                let indexOfOption = index * 2
                let indexOfValue = indexOfOption + 1
                let option = getOption(args[indexOfOption])

                switch option {
                case .input:
                    let path = args[indexOfValue]
                    config[option] = Path(path)
                case .output:
                    let path = args[indexOfValue]
                    config[option] = Path(path)
                default:
                    throw Errors.argsInvalid
                }
            }

            return config

        }
        else {
            throw Errors.argsInvalid
        }
    }
}
