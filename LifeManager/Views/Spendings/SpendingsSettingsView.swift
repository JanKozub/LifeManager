//
//  SettingsWindow.swift
//  LifeManager
//
//  Created by Jan Kozub on 25/07/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SpendingsSettingsView: View {
    @Binding var isShowing: Bool
    @State private var userInput: String = ""
    @State var context: ModelContext
    
    @State var categories: [PaymentCategory]
    
    var body: some View {
        HStack {
            VStack {
                Button(action: {
                    isShowing = false
                }) 
                {Text("Go Back").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    try? context.delete(model: Year.self)
                }) 
                {Text("Delete Data").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    DataExportService.exportToJSON(context: context)
                }) 
                {Text("Save data to json").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding()
            
            Divider()
            
            VStack {
                HStack {
                    TextField("Enter text here", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        context.insert(PaymentCategory(name: userInput))
                        try? context.save()
                        userInput = ""
                    }) {
                        Text("Submit")
                    }
                }.frame(alignment: .top).padding()
                List {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button("Delete") {
                                context.delete(category)
                            }
                        }
                    }
                }.frame(alignment: .top)
            }
        }
    }
}
