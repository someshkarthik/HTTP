//
//  Bash.swift
//  UdemyVideoDownloader
//
//  Created by somesh-8758 on 07/05/20.
//  Copyright © 2020 Somesh-8758. All rights reserved.
//

import Foundation

protocol Executable {
    func execute(commandName: String) -> String?
    func execute(commandName: String, arguments: [String]) -> String?
}
final class Bash: Executable {
    
    // MARK: - CommandExecuting
    @discardableResult
    func execute(commandName: String) -> String? {
        return execute(commandName: commandName, arguments: [])
    }
    
    @discardableResult
    func execute(commandName: String, arguments: [String]) -> String? {
        guard var bashCommand = execute(command: "/bin/bash" , arguments: ["-l", "-c", "which \(commandName)"]) else { return "\(commandName) not found" }
        bashCommand = bashCommand.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return execute(command: bashCommand, arguments: arguments)
    }
    
    private func execute(command: String, arguments: [String] = []) -> String? {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        return output
    }
}


let bash: Bash = Bash()
