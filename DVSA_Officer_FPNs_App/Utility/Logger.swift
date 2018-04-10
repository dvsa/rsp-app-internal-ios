//
//  Logger.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 26/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger

let kLogFileName = "RSP_Log"

func cacheDirectory() -> URL {
    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return urls[urls.endIndex - 1]
}

let log: XCGLogger = {
    // Setup XCGLogger (Advanced/Recommended Usage)
    // Create a logger object with no destinations
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)

    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.appleSystemLogDestination")

    // Optionally set some configuration options
    #if DEBUG
        systemDestination.outputLevel = .verbose
    #else
        systemDestination.outputLevel = .severe
    #endif

    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true

    // Add the destination to the logger
    log.add(destination: systemDestination)

    // Create a file log destination
    let logPath: URL = cacheDirectory().appendingPathComponent("\(kLogFileName).txt")
    let attributes =  [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
    let autoRotatingFileDestination = AutoRotatingFileDestination(writeToFile: logPath,
                                                                  identifier: "advancedLogger.fileDestination",
                                                                  shouldAppend: true,
                                                                  attributes: attributes,
                                                                  maxFileSize: 1024 * 1,
                                                                  maxTimeInterval: 0)
    // Optionally set some configuration options
    autoRotatingFileDestination.outputLevel = .error
    autoRotatingFileDestination.showLogIdentifier = false
    autoRotatingFileDestination.showFunctionName = true
    autoRotatingFileDestination.showThreadName = true
    autoRotatingFileDestination.showLevel = true
    autoRotatingFileDestination.showFileName = true
    autoRotatingFileDestination.showLineNumber = true
    autoRotatingFileDestination.showDate = true
    autoRotatingFileDestination.targetMaxLogFiles = 10
    // Process this destination in the background
    autoRotatingFileDestination.logQueue = XCGLogger.logQueue

    // Add colour (using the ANSI format) to our file log, you can see the colour when `cat`ing or `tail`ing the file in Terminal on macOS
    let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
    ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
    ansiColorLogFormatter.colorize(level: .debug, with: .black)
    ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
    ansiColorLogFormatter.colorize(level: .warning, with: .red, options: [.faint])
    ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
    ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
    autoRotatingFileDestination.formatters = [ansiColorLogFormatter]

    // Add the destination to the logger
    log.add(destination: autoRotatingFileDestination)

    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()

    let emojiLogFormatter = PrePostFixLogFormatter()
    emojiLogFormatter.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
    emojiLogFormatter.apply(prefix: "🔹🔹🔹 ", postfix: " 🔹🔹🔹", to: .debug)
    emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: " ℹ️ℹ️ℹ️", to: .info)
    emojiLogFormatter.apply(prefix: "⚠️⚠️⚠️ ", postfix: " ⚠️⚠️⚠️", to: .warning)
    emojiLogFormatter.apply(prefix: "‼️‼️‼️ ", postfix: " ‼️‼️‼️", to: .error)
    emojiLogFormatter.apply(prefix: "💣💣💣 ", postfix: " 💣💣💣", to: .severe)
    log.formatters = [emojiLogFormatter]

    return log
}()

func logFiles() -> [URL]? {
    let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
    if let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory(),
                                                                includingPropertiesForKeys: nil,
                                                                options: options) {
        let logFiles = files.filter { file in
            file.lastPathComponent.contains(kLogFileName)
        }
        return logFiles
    }
    return nil
}
