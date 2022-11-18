//
//  SignupRequestDTO.swift
//  Mogakco
//
//  Created by 김범수 on 2022/11/16.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import Foundation

struct SignupRequestDTO: Encodable {
    let email: String
    let password: String
    let name: String
    let languages: [String]
    let careers: [String]
}
