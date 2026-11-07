//
//  ContentView.swift
//  SachDoc
//
//  Created by Le Hung on 4/11/26.
//

import SwiftUI

class SampleObject {
    var onAction: (() -> Void)?
    var name = "Sample Object"
    
    func doAction() {
        onAction = { [weak self] in
            guard let self else { return }
            print(self.name)
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("Click") {
                let obj = SampleObject()
                obj.doAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
