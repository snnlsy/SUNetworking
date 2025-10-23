//
//  SUHeaderValidator.swift
//  SUNetworking
//
//  Created by SUNetworking
//

import Foundation

// MARK: - SUHeaderValidator

/// Validates HTTP headers according to RFC 7230 standards.
public struct SUHeaderValidator {
    
    /// Validates a header key-value pair.
    ///
    /// - Parameters:
    ///   - key: The header field name.
    ///   - value: The header field value.
    /// - Returns: True if valid, false otherwise.
    public static func isValid(key: String, value: String) -> Bool {
        return isValidHeaderName(key) && isValidHeaderValue(value)
    }
    
    /// Validates all headers in a dictionary.
    ///
    /// - Parameter headers: Dictionary of headers to validate.
    /// - Returns: Dictionary containing only valid headers.
    public static func validate(headers: [String: String]) -> [String: String] {
        return headers.filter { isValid(key: $0.key, value: $0.value) }
    }
    
    private static func isValidHeaderName(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        
        let validCharacters = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-_"))
        
        return name.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }
    
    private static func isValidHeaderValue(_ value: String) -> Bool {
        // Check for control characters except tab
        let invalidCharacters = CharacterSet.controlCharacters
            .subtracting(CharacterSet(charactersIn: "\t"))
        
        return value.unicodeScalars.allSatisfy { !invalidCharacters.contains($0) }
    }
}
