//
//  ContentView.swift
//  My_Api_uppgift
//
//  Created by elias on 2024-10-26.
//

import SwiftUI

struct ContentView: View {
    @State private var artistName: String = ""
    @State private var track: String = ""
    @State private var errorMessage: String = ""
    @State private var lyrics: String = ""
    @State private var isLoading: Bool = false
    @State private var fontSize: CGFloat = 12
    @State private var isEditing = false
    
    func loadLyrics() async {
        guard !artistName.isEmpty, !track.isEmpty else {
            errorMessage = "Please enter both artist and track names."
            return
        }
        lyrics = ""
        isLoading = true
        defer { isLoading = false }
        
        let result = await LoadLyricsData(artist: artistName, track: track)
        
        if result.success {
            lyrics = result.lyrics ?? ""
            errorMessage = ""
        } else {
            errorMessage = result.error ?? "An unexpected error occurred."
        }
    }
    
    var body: some View {
        VStack {
            Text(errorMessage)
                .foregroundColor(.red)
                .padding(.bottom, 5)
            
            TextField("Artist", text: $artistName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Track", text: $track)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await loadLyrics()
                }
            }) {
                Text("Load Lyrics")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(isLoading)
            
            if !lyrics.isEmpty {
                Text("Lyrics:")
                    .font(.headline)
                    .padding(.top)
                
                ScrollView {
                    Text(lyrics)
                        .padding()
                        .font(.custom("Helvetica Neue", size: fontSize))
                }
                .frame(maxHeight: 300)
                Text("Text size")
                Slider(
                    value: $fontSize,
                        in: 12...24,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                ).padding(10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
