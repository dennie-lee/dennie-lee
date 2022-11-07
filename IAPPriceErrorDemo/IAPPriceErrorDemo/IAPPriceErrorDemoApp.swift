//
//  IAPPriceErrorDemoApp.swift
//  IAPPriceErrorDemo
//
//  Created by liqinghua on 2022/11/3.
//

import SwiftUI

@main
struct IAPPriceErrorDemoApp: App {
    init(){
        IAPManager.shared.startManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
