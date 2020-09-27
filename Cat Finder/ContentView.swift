//
//  ContentView.swift
//  Cat Finder
//
//  Created by Takahiko Inayama on 2020/09/27.
//

import SwiftUI
import URLImage

struct ContentView: View {
    let TWEET_URL_BASE = "https://twitter.com/intent/tweet"
    @State var imageUrl: String? = nil
    
    var body: some View {
        VStack {
            Button(action: {load()}, label: {
                Text("Load")
            })

            if let imageUrl = imageUrl,
               let url = URL(string: imageUrl) {
                URLImage(url, placeholder: { _ in
                    Image("Placeholder")
                }) { proxy in
                    proxy.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                    }
                
                Button(action: {
                    var components = URLComponents(string: TWEET_URL_BASE)!
                    components.queryItems = [
                        URLQueryItem(name: "text", value: "I found cute cat!"),
                        URLQueryItem(name: "url", value: imageUrl)
                    ]
                    if let url = components.url {
                        if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:])
                        }
                    }
                }, label: {
                    Text("Tweet")
                })
            } else {
                Image("Placeholder")
            }
        }.onAppear(perform: {
            load()
        })
    }
    
    func load() {
        imageUrl = nil
        let url = URL(string: "https://api.thecatapi.com/v1/images/search")!
        var request = URLRequest(url: url)
        request.setValue("2d2aee74-de17-4c98-92b9-c07b64190171", forHTTPHeaderField: "x-api-key")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
            guard let root = json as? [[String: Any]] else { return }
            guard root.count > 0 else { return }
            
            let result = root[0]
            if let url = result["url"] as? String {
                imageUrl = url
            }
        }

        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
