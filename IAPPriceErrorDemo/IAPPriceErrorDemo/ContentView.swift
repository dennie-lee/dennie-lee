//
//  ContentView.swift
//  IAPPriceErrorDemo
//
//  Created by liqinghua on 2022/11/3.
//

import SwiftUI

struct ContentView: View {
    @State private var price = "请点击订阅..."
    @State private var loading = false
    
    var body: some View {
        ZStack{
            VStack{
                Text("苹果服务器响应的价格：\(price)")
                
                Button {
                    startToIap()
                } label: {
                    Text("订阅")
                        .frame(width: 150, height: 50)
                }
            }
            
            VStack{
                if loading{
                    ProgressView()
                        .padding(.all,40)
                }
            }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
    }
    
    private func startToIap(){
        loading = true
        let monthId = "com.taksoul.month"
        IAPManager.shared.normalBuy(produntID: monthId) { type in
            switch type {
            case .success:
                loading = false
                break
            case .fail:
                loading = false
                break
            case .price(let price):
                self.price = price
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
