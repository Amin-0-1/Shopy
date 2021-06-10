//
//  MeTapViewModel.swift
//  Shopy
//
//  Created by Amin on 07/06/2021.
//  Copyright © 2021 mohamed youssef. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MeModelType{
    
    func fetchFavProducts()
    func getUserName() -> String
    func fetchOrders(status: FinancialStatus)
    func getFormattedDate(date:String) -> String?
    
    var favProductsObservable: Driver<[FavouriteProduct]>?{get}
    var ordersObservable: Driver<[Order]>?{get}
    var orderProductsObservable : Driver<[Product]>?{get}
    var loadingObservable: Driver<Bool>{get}
}

class MeTapViewModel:MeModelType {

    var favProductsObservable: Driver<[FavouriteProduct]>?
    var ordersObservable: Driver<[Order]>?
    var orderProductsObservable: Driver<[Product]>?
    var loadingObservable: Driver<Bool>
    
    private var favProductsSubject = PublishSubject<[FavouriteProduct]>()
    private var ordersSubject = PublishSubject<[Order]>()
    private var orderProductSubject = PublishSubject<[Product]>()
    private var loadingSubject = PublishSubject<Bool>()
    
    var remote:RemoteDataSource!
    var dispatchGroup : DispatchGroup!
    init() {
        favProductsObservable = favProductsSubject.asDriver(onErrorJustReturn: [])
        ordersObservable = ordersSubject.asDriver(onErrorJustReturn: [])
        orderProductsObservable = orderProductSubject.asDriver(onErrorJustReturn: [])
        loadingObservable = loadingSubject.asDriver(onErrorJustReturn: true)
        remote = RemoteDataSource()
        dispatchGroup = DispatchGroup()
    }
    
    func fetchFavProducts() {
        let localData = FavouritesPersistenceManager.shared
        guard let favourites = localData.retrieveFavourites() else {
            return
        }
        self.favProductsSubject.asObserver().onNext(favourites)
    }
    
    func fetchOrders(status: FinancialStatus)  {
        
        loadingSubject.asObserver().onNext(true)
        remote.fetchOrders(financialStatus: status) { [unowned self] (result) in
            switch result{
            case .success(let response):
                guard let orders = response?.orders else {return}
                print("success")
                self.ordersSubject.asObserver().onNext(orders)
                self.loadingSubject.onNext(false)

            case .failure(let error):
                AppCommon.shared.showSwiftMessage(title: "Error", message: error.localizedDescription , theme: .error)
                self.loadingSubject.onNext(false)

            }
            
        }
    }
    
    
    func isUserLoggedIn() -> Bool {
        let value = MyUserDefaults.getValue(forKey: .loggedIn)
        guard let isLoggedIn = value else {return false}
        
        return (isLoggedIn as! Bool) ? true : false
    }
    
    func getUserName() -> String {
        return MyUserDefaults.getValue(forKey: .username) as! String
    }
    
    func fetchOrderProducts(orderLineItems: [LineItems]) {
        
        var products = [Product]()
        
        for item in orderLineItems{
            guard let id = item.productID else {return}
            dispatchGroup.enter()
            remote.getProductElement(productId: String(id)) { [unowned self] (result) in
                
                self.dispatchGroup.leave()
                switch result{
                    case .success(let product):
                        guard let product = product else {return}
                        products.append(product)
                        print(products)
                    case .failure(let error):
                        print(error)
                    
                }
            }
            
        }
        
        dispatchGroup.notify(queue:.main) { [unowned self] in
            self.orderProductSubject.asObserver().onNext(products)
        }
    }
    
    func getFormattedDate(date: String) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // api iso format
        if let date = formatter.date(from: date) {
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            return formatter.string(from: date)
        }
        return nil
    }
    
}
