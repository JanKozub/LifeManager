//
//  TableView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct TableView: View {
    @Binding var payments: [Payment];
    @State private var personalSum: Double = 0
    @State private var refundSum: Double = 0
    @State private var otherSum: Double = 0
    @State private var incomeSum: Double = 0
    
    var body: some View {
        let currency = payments.count > 0 ? payments[0].currency : ""
        GeometryReader { reader in
            VStack {
                HStack {
                    HeaderText(text: "Issued(D)", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Transaction(D)", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Title", percentage: 0.36, size: reader.size)
                    HeaderText(text: "Message", percentage: 0.18, size: reader.size)
                    HeaderText(text: "Amount", percentage: 0.07, size: reader.size)
                    HeaderText(text: "Balance", percentage: 0.07, size: reader.size)
                    HeaderText(text: "Category", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Type", percentage: 0.08, size: reader.size)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                
                List {
                    ForEach($payments, id: \.self) {$payment in
                        PaymentView(payment: $payment, width: .constant(reader.size.width), onPaymentChanged: { newPayment in
                            calculateSums()
                        })
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, maxHeight: abs(reader.size.height - 60))
                
                HStack {
                    CurrencyText(title: "Personal", value: $personalSum, currency: currency)
                    CurrencyText(title: "Refund", value: $refundSum, currency: currency)
                    CurrencyText(title: "Other", value: $otherSum, currency: currency)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .frame(maxWidth: .infinity, maxHeight: reader.size.height)
        }
        .toolbar {
            ToolbarItemGroup {
                Text("Currency: " + currency)
            }
        }
        .onAppear(perform: {
            calculateSums()
        })
        .padding(.top, 1)
    }
    
    private func calculateSums() {
        personalSum = 0
        refundSum = 0
        otherSum = 0
        incomeSum = 0
        
        for(_, payment) in payments.enumerated() {
            if payment.amount < 0 {
                switch payment.type {
                case .personal: personalSum += abs(payment.amount)
                case .refunded: refundSum += abs(payment.amount)
                case .other: otherSum += abs(payment.amount)
                }
            } else if payment.amount > 0 {
                incomeSum += abs(payment.amount)
            }
        }
    }
}

#Preview {
    TableView(payments: .constant([]))
}
