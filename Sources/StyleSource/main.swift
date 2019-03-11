//
//  main.swift
//  StyleSource
//
//  Created by Bruno Fernandes on 9/7/18.
//  Copyright © 2018 bfs. All rights reserved.
//

import Foundation
import Core

let cmd = Command(cliArguments: Array(ProcessInfo.processInfo.arguments.dropFirst()))
cmd.staticMode()
