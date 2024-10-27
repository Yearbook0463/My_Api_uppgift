//
//  ApiService.swift
//  My_Api_uppgift
//
//  Created by elias on 2024-10-26.
//

import Foundation

func LoadLyricsData(artist: String, track: String) async -> ServiceResponse {
    let lyricsApiUrlString = "https://api.lyrics.ovh/v1/\(artist)/\(track)"
    
    guard let lyricsUrl = URL(string: lyricsApiUrlString) else {
        return ServiceResponse(success: false, lyrics: nil, error: "Invalid URL")
    }
    
    do {
        let (data, response) = try await URLSession.shared.data(from: lyricsUrl)
        
        // Ensure we received a valid HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            return ServiceResponse(success: false, lyrics: nil, error: "Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            // Decode JSON on a successful 200 status
            if let decodedResponse = try? JSONDecoder().decode(SuccessResponse.self, from: data) {
                return ServiceResponse(success: true, lyrics: decodedResponse.lyrics, error: nil)
            } else {
                return ServiceResponse(success: false, lyrics: nil, error: "Failed to decode response")
            }
            
        case 400..<500:
            // Handle client errors
            if let decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                return ServiceResponse(success: false, lyrics: nil, error: decodedError.error)
            } else {
                return ServiceResponse(success: false, lyrics: nil, error: "Client error: \(httpResponse.statusCode)")
            }
            
        case 500...:
            // Handle server errors
            return ServiceResponse(success: false, lyrics: nil, error: "Server error: \(httpResponse.statusCode)")
            
        default:
            return ServiceResponse(success: false, lyrics: nil, error: "Unexpected status code: \(httpResponse.statusCode)")
        }
        
    } catch {
        return ServiceResponse(success: false, lyrics: nil, error: "Failed to retrieve API data: \(error.localizedDescription)")
    }
}
