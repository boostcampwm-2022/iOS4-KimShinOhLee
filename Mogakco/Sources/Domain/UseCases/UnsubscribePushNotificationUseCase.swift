//
//  UnsubscribePushNotificationUseCase.swift
//  Mogakco
//
//  Created by 김범수 on 2022/12/07.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import RxSwift

struct UnsubscribePushNotificationUseCase: UnsubscribePushNotificationUseCaseProtocol {
    
    var pushNotificationService: PushNotificationServiceProtocol?
    
    func excute(topic: String) -> Observable<Void> {
        return pushNotificationService?.unsubscribeTopic(topic: topic) ?? .empty()
    }
}
