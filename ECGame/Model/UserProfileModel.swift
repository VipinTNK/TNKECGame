//
//  UserProfileModel.swift
//  ECGame
//
//  Created by hfcb on 20/01/20.
//  Copyright © 2020 tnk. All rights reserved.
//

import UIKit
import ObjectMapper

class UserProfileModel: Mappable {
       var code = 0
       var data : UserProfileDataModel?
       var status = false
       var message = ""
       
       required init?(map: Map) {
           //
       }
       
       func mapping(map: Map) {
           code <- map["code"]
           status <- map["status"]
           message <- map["message"]
           data <- map["data"]
      }
   }
       
   class UserProfileDataModel: Mappable {
       
    var id : Int = 0
    var userId : Int = 0
    var name : String = ""
     var userApiId : String = ""
     var userBalance : Int = 0
     var email : String = ""
     var userIp : String = ""
     var password: String = ""
     var api_token: String = ""
     var lastLoginAt: String = ""
     var lastIpLoginAt: String = ""
     var lastActivity: String = ""
     var remember_token: String = ""
     var created_at: String = ""
     var updated_at: String = ""
    var userStatus : Bool = false
    var webId : Int = 0
    var isBanned : Bool = false
     var avatar: String = ""
     var device : String = ""
     var country: String = ""
     var gender : Int = 0
    var rollingAmount : Int = 0

       
       required init?(map: Map) {
           //
       }
       
       func mapping(map: Map) {
           id <- map["id"]
           userId <- map["userId"]
          name <- map["name"]
          userApiId <- map["userApiId"]
          userBalance <- map["userBalance"]
          email <- map["email"]
          userIp <- map["userIp"]
          password <- map["password"]
          api_token <- map["api_token"]
          lastLoginAt <- map["lastLoginAt"]
          lastIpLoginAt <- map["lastIpLoginAt"]
          lastActivity <- map["lastActivity"]
          remember_token <- map["remember_token"]
          created_at <- map["created_at"]
          updated_at <- map["updated_at"]
          userStatus <- map["userStatus"]
          webId <- map["webId"]
          isBanned <- map["isBanned"]
          avatar <- map["avatar"]
          device <- map["device "]
          country <- map["country"]
          gender <- map["gender"]
          rollingAmount <- map["rollingAmount"]
       }
   }
