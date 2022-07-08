//
//  SDKConfiguration.swift
//  Mediatag-sdk-demo-ios
//
//  Created by Sergey Zhidkov on 08.07.2022.
//

import Foundation
import MediaTagSDK
struct SDKPlugin: PluginType {
  func prepare(_ request: URLRequest) -> URLRequest {
    ///  some request modification code
    return request
  }
}
class Configuration: ConfigurationType {

  var uidc: Int?

  var cid: String = "asdasdas"

  var tms: String = "sadasdasd"

  var hid: String?

  var uid: String?

  var baseUrl: URL {
      return URL(string: "https://tns-counter.online/api/post-event/?")!
  }
}
