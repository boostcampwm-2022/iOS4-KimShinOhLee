//
//  StudyTabCoordinator.swift
//  Mogakco
//
//  Created by 신소민 on 2022/11/17.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import UIKit

final class StudyTabCoordinator: Coordinator, StudyTabCoordinatorProtocol {
    
    weak var delegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showStudyList()
    }
    
    func showStudyList() {
        let viewController = StudyListViewController(coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStudyDetail() {
        let viewModel = StudyDetailViewModel()
        viewModel.coordinator = self
        let studyDetailViewController = StudyDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(studyDetailViewController, animated: true)
    }
    
    func showChatDetail() {
        let viewModel = ChatViewModel(coordinator: self)
        let chatViewController = ChatViewController(viewModel: viewModel)
        navigationController.pushViewController(chatViewController, animated: true)
    }
}
