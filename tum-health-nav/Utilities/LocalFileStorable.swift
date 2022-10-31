//
//  LocalFileStorable.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 11.07.20.
//  Copyright © 2020 TUM. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - LocalFileStorable
/// An object that can be represented and stored as a local file
protocol LocalFileStorable: Codable {
    static var fileName: String { get }
}

// MARK: Extension: LocalFileStorable: URL
extension LocalFileStorable {
    
    /// The URL of the parent folder to store the LocalFileStorable in
    static var localStorageURL: URL {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the document directory in the user's home directory.")
        }
        return documentsDirectory.appendingPathComponent(Self.fileName).appendingPathExtension("json")
    }
}

// MARK: Extension: LocalFileStorable: Load & Save
extension LocalFileStorable {
    
    /**
     Load LocalFileStorables from a file
     - returns: deserialised object
     */
    static func loadFromFile() -> Self? {
        do {
            let fileWrapper = try FileWrapper(url: Self.localStorageURL, options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("Could not load \(Self.self)s, because of \(error). The Model uses a new Object. ")
            return nil
        }
    }
    
    /**
     Save a collection of LocalFileStorables to a file
     - parameters:
        - element: object to be saved
     */
    static func saveToFile(_ element: Self) {
        do {
            let data = try JSONEncoder().encode(element)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: Self.localStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
        } catch _ {
            print("Could not save \(Self.self)s")
        }
    }
}
