//
//  EntryNavigator.swift
//  Shopy
//
//  Created by Amin on 28/05/2021.
//  Copyright © 2021 mohamed youssef. All rights reserved.
//

import UIKit

class EntryNavigator: UITabBarController {
    
//    var tap:Bool!?
    var customer:CustomerClass!
    var customerID:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(EntryNavigator.respond), name: NSNotification.Name(rawValue: "EntryScreen"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let customer = customer{
            guard  let register = self.viewControllers![0] as? RegisterViewController else {return}
            register.customer = customer
            register.customerID = customerID
        }
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }    
    @objc func respond(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["key"] as? Bool{
                self.selectedIndex = id ? 1 : 0
            }
            
        }
    }

}
