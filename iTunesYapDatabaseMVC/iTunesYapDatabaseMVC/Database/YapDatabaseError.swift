//
//  YapDatabaseError.swift
//  iTunesYapDatabaseMVC
//
//  Created by Ибрагим Габибли on 30.12.2024.
//

import Foundation

enum YapDatabaseError: Error {
    case databaseInitializationFailed
    case encodingFailed(Error)
    case decodingFailed(Error)
}
