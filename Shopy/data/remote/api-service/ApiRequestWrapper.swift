//
//  ApiRequestWrapper.swift
//  Shopy
//
//  Created by Mahmoud Elattar on 20/05/2021.
//  Copyright © 2021 mohamed youssef. All rights reserved.
//

import Foundation
import Alamofire

enum Endpoint{
    case staticEndpoint
    case dynamicEndPoint(path : String)
}

enum Task {
    case requestPlain
    case requestParameters(parameters :[String:String] , encoding : ParameterEncoding)
}

protocol ApiRequestWrapper {
    var baseURL  : String           {get}
    var endpoint : String           {get}
    var task     : Task             {get}
    var headers  : [String:String]? {get}
    
}
