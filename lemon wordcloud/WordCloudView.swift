//
//  WordCloudView.swift
//  lemon wordcloud
//
//  Created by いしづかれい on 2024/09/16.
//
import SwiftUI

struct WordCloudView: View {
    @State private var image: UIImage?

    var body: some View {
        VStack {
            // Title
            Text("Word Cloud Generator")
                .font(.title)
                .padding()
            
            // Show word cloud
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("No image generated")
            }
            
            Button("Generate Word Cloud") {
                generateWordCloud(wordsWithScores: [
                    "Python": 90,
                    "Java": 80,
                    "C++": 70,
                    "JavaScript": 85,
                    "HTML": 50,
                    "CSS": 55,
                    "Ruby": 60,
                    "Swift": 65,
                    "Kotlin": 75
                ])
            }
            .padding()
        }
    }
    
    func generateWordCloud(wordsWithScores: [String: Int]) {
        guard let url = URL(string: "http://127.0.0.1:5000/generate_wordcloud") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["words_with_scores": wordsWithScores]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                if let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = uiImage
                    }
                } else {
                    print("Failed to load image from data.")
                }
            } else if let error = error {
                print("Error making API request: \(error)")
            }
        }.resume()
    }
}

#Preview {
    WordCloudView()
}
