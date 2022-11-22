//
//  AuthCoordinator.swift
//  Mogakco
//
//  Created by 신소민 on 2022/11/16.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import UIKit

final class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    weak var delegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    func showAutoLogin() {
    }
    
    func showLogin() {
        let localUserDataSource = UserDefaultsUserDataSource()
        let remoteUserDataSource = RemoteUserDataSource(provider: Provider.default)
        let authService = FBAuthService()
        let authRepository = AuthRepository(authService: authService)
        let userRepository = UserRepository(
            localUserDataSource: localUserDataSource,
            retmoteUserDataSource: remoteUserDataSource
        )
        let loginUseCase = LoginUseCase(
            authRepository: authRepository,
            userRepository: userRepository
        )
        let viewModel = LoginViewModel(coordinator: self, loginUseCase: loginUseCase)
        let loginViewController = LoginViewController(viewModel: viewModel)
        navigationController.viewControllers = [loginViewController]
    }
    
    func showRequiredSignup() {
        let signupCoordinator = RequiredSignupCoordinator(navigationController)
        childCoordinators.append(signupCoordinator)
        signupCoordinator.delegate = self
        signupCoordinator.start()
    }
    
    func showAdditionalSignup(email: String? = nil, password: String? = nil) {
        let socialSignupCoordinator = AdditionalSignupCoordinator(navigationController)
        childCoordinators.append(socialSignupCoordinator)
        socialSignupCoordinator.delegate = self
        socialSignupCoordinator.start()
    }
    
    func finish() {
        delegate?.coordinatorDidFinish(child: self)
    }
}

extension AuthCoordinator: AuthCoordinatorFinishDelegate {
    
    func autoLoginCoordinatorDidFinish(child: Coordinator, success: Bool) {
        finish(child)
        if success {
            delegate?.coordinatorDidFinish(child: self)
        } else {
            showLogin()
        }
    }
    
    func requiredSignupCoordinatorDidFinish(child: Coordinator, email: String?, password: String?) {
        finish(child)
        showAdditionalSignup(email: email, password: password)
    }
    
    func additionalSignupCoordinatorDidFinish(child: Coordinator, success: Bool) {
        finish(child)
        if success {
            delegate?.coordinatorDidFinish(child: self)
        } else {
            showLogin()
        }
    }
}
