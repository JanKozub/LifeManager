//
//  SpendingsMainView.swift
//  LifeManager
//
//  Created by Jan Kozub on 30/07/2024.
//

import Charts

import SwiftUI

struct SpendingsMainView: View {
    @Binding var payments: [Payment]
    @Binding var isShowingSettings: Bool
    
    @State private var displayMonth: String = MonthName.currentMonth.name
    @State private var displayYear: String = "Year"
    @State private var currency: Currency = .pln
    @State private var top10Payments = ["1.test", "2.test", "3.test", "4.test", "5.test", "6.test", "7.test", "8.test", "9.test", "10.test"]
    
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State private var chartEntries: [ChartEntry] = []
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    switch displayYear {
                    case "Year":
                        Chart(chartEntries) { entry in
                            ForEach(categories) { category in
                                BarMark(
                                    x: .value("Shape Type", entry.monthName.name),
                                    y: .value("Total Count", entry.sums[category] ?? 0.0)
                                ).foregroundStyle(by: .value("Shape Color", category.name))
                            }
                        }.chartForegroundStyleScale(range: graphColors(for: categories))
                    case "Month":
                        HStack {
                            ForEach(PaymentType.allCases) { type in
                                Chart(chartEntries) { entry in
                                    if entry.paymentType == type {
                                        ForEach(categories) { category in
                                            SectorMark(
                                                angle: .value(Text(verbatim: category.name), entry.sums[category] ?? 0),
                                                angularInset: 3
                                            ).foregroundStyle(by: .value(Text(verbatim: category.name), category.name))
                                        }
                                    }
                                }
                            }
                        }
                    default: HStack {}
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                
                Divider()
                
                HStack {
                    VStack {
                        List {
                            ForEach(top10Payments, id: \.self) { el in
                                Text(el)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    Divider()
                    VStack {
                        Button(action: {
                            let panel = NSOpenPanel()
                            panel.begin { result in
                                if result == .OK, let fileURL = panel.url {
                                    payments = DataParseService.loadSantanderPaymentsFromCSV(file: fileURL)
                                }
                            }
                        }) {Text("Import new month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        
                        Button(action: {
                        }) {Text("Edit this month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        
                        Button(action: {
                            isShowingSettings = true
                        }) {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                DropdownMenu(selectedCategory: displayMonth, elements: MonthName.allCasesNames, onChange: Binding(
                    get: {{ newValue in
                        displayMonth = newValue
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
                
                DropdownMenu(selectedCategory: displayYear, elements: ["Year", "Month"], onChange: Binding(
                    get: {{ newValue in
                        displayYear = newValue
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
                
                DropdownMenu(selectedCategory: currency.name, elements: Currency.allCasesNames, onChange: Binding(
                    get: {{ newValue in
                        currency = Currency.nameToType(name: newValue)
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
            }
        }.onAppear(perform: {
            refreshChart()
        })
        .padding(.all)
    }
    
    private func refreshChart() {
        chartEntries = []
        if let year = years.first(where: {$0.number == YearName.currentYear}) {
            if displayYear == "Year" {
                for monthName in MonthName.allCases {
                    var chartEntry = ChartEntry(monthName: monthName, categories: categories)
                    
                    for month in year.months.filter({$0.monthName == monthName}) {
                        for type in PaymentType.allCases {
                            chartEntry.paymentType = type
                            
                            addSumsToEntry(entry: &chartEntry, sums: month.spendings[type]!.sums, currency: month.currency)
                        }
                    }
                    chartEntries.append(chartEntry)
                }
            } else if displayYear == "Month" {
                if let month = year.months.first(where: {$0.monthName.name == displayMonth}) {
                    for type in PaymentType.allCases {
                        var chartEntry = ChartEntry(monthName: MonthName.nameToType(name: displayMonth), paymentType: type, categories: categories)
                        
                        addSumsToEntry(entry: &chartEntry, sums: month.spendings[type]!.sums, currency: month.currency)
                        chartEntries.append(chartEntry)
                    }
                }
            }
        }
    }
    
    private func exchangeValue(value: Optional<Double>, fromCur: Currency) -> Double {
        return (value ?? 0) * Currency.exchangeRate(from: fromCur, to: currency)
    }
    
    private func addSumsToEntry(entry: inout ChartEntry, sums: Dictionary<String, Double>, currency: Currency) {
        for category in categories {
            entry.sums[category]! += exchangeValue(value: sums[category.name], fromCur: currency)
        }
    }
    
    func graphColors(for input: [PaymentCategory]) -> [Color] {
        var returnColors = [Color]()
        for _ in input {
            returnColors.append(Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)))
        }
        return returnColors
    }
}

#Preview {
    SpendingsMainView(payments: .constant([]), isShowingSettings: .constant(false), years: [], categories: [])
}
