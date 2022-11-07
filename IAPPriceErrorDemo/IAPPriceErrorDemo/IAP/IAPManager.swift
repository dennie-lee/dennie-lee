//
//  IAPManager.swift
//  IAPPriceErrorDemo
//
//  Created by liqinghua on 2022/11/3.
//

import Foundation
import StoreKit

enum IAPResultType{
    case success
    case fail
    case price(price:String)
}

class IAPManager: NSObject {
    static let shared = IAPManager()
    private var complete : ((IAPResultType) -> ())?
    
    public func normalBuy(produntID:String,complete:@escaping (IAPResultType) -> ()) {
        self.complete = complete
        self.buy(produntID: produntID)
    }
    
    //请求去内购
    /**请求去内购、订阅某个商品*/
    private func buy(produntID:String) {
        self.startIap(produntIDs: [produntID])
    }
    
    private func startIap(produntIDs:[String]){
        //区获取商品
        print("🍎🍎🍎🍎🍎🍎🍎订阅开始：订阅的商品ID为->\(produntIDs)")
        let productRequest = SKProductsRequest(productIdentifiers: Set(produntIDs))
        productRequest.delegate = self
        productRequest.start()
    }
    
    /// 启动app 即开启
    public func startManager(){
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
    }
    
    /// 关闭app再去停止
    public func stopManager(){
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}

//MARK: 购买SKPaymentTransactionObserver
extension IAPManager : SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        _ = transactions.map { (transaction)in
            switch transaction.transactionState{
            case .purchasing:
                break
            case .purchased:
                autoreleasepool{
                    self.purchaceSuccessHandle(transaction: transaction, transactions: transactions)
                }
                break
            case .restored:
                self.purchaceSuccessHandle(transaction: transaction, transactions: transactions)
                break
            case .failed:
                finishTransaction(transaction: transaction)
                self.complete?(.fail)
                break
            case .deferred:
                finishTransaction(transaction: transaction)
                self.complete?(.fail)
                break
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
    }
}

// MARK:查询 SKProductsRequestDelegate
extension IAPManager : SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let product = response.products.first!
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let formattedPrice = numberFormatter.string(from: product.price)
        self.complete?(.price(price: formattedPrice ?? ""))
        
        print("🍎🍎🍎🍎🍎🍎🍎：订阅的商品ID响应的信息(商品ID)->\(product.productIdentifier)")
        print("🍎🍎🍎🍎🍎🍎🍎：订阅的商品ID响应的信息(商品价格)->\(formattedPrice ?? "")")
        print("🍎🍎🍎🍎🍎🍎🍎：请开始注意 --该处响应的价格和后面的弹窗显示是否一致-- ")
        
        let payment = SKPayment(product: response.products.first!)
        SKPaymentQueue.default().add(payment)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.complete?(.fail)
    }
}

extension IAPManager{
    ///订单购买成功
    private func purchaceSuccessHandle(transaction:SKPaymentTransaction,transactions: [SKPaymentTransaction]){
        self.complete?(.success)
        finishTransaction(transaction: transaction)
    }
    
    /**交易完成的回调*/
    private func finishTransaction(transaction:SKPaymentTransaction){
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}


extension Double{
    func stringValue() -> String {
        var str = "\(self)"
        if str.hasSuffix(".0") || str.hasSuffix(".00") {
            str = str.replacingOccurrences(of: ".0", with: "")
            str = str.replacingOccurrences(of: ".00", with: "")
        }
        return str
    }
}
