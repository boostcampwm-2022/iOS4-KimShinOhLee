//
//  StudyDetailCoordinator.swift
//  Mogakco
//
//  Created by 신소민 on 2022/12/03.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import UIKit

import RxSwift

enum StudyDetailCoordinatorResult {
    case back
}

final class StudyDetailCoordinator: BaseCoordinator<StudyDetailCoordinatorResult> {
    
    private let id: String
    private let finish = PublishSubject<StudyDetailCoordinatorResult>()
    
    init(id: String, _ navigationController: UINavigationController) {
        self.id = id
        super.init(navigationController)
    }
   
    override func start() -> Observable<StudyDetailCoordinatorResult> {
        showStudyDetail()
        return finish
            .do(onNext: { [weak self] _ in self?.popTabbar(animated: true) })
    }
    
    // MARK: - 스터디 상세
    
    func showStudyDetail() {
        let studyRepository = StudyRepository(
            studyDataSource: StudyDataSource(provider: Provider.default),
            localUserDataSource: UserDefaultsUserDataSource(),
            remoteUserDataSource: RemoteUserDataSource(provider: Provider.default),
            chatRoomDataSource: ChatRoomDataSource(provider: Provider.default)
        )
        
        let viewModel = StudyDetailViewModel(
            studyID: id,
            studyUsecase: StudyDetailUseCase(repository: studyRepository),
            hashtagUseCase: HashtagUsecase(
                hashtagRepository: HashtagRepository(
                    localHashtagDataSource: HashtagDataSource()
                )
            ),
            userUseCase: UserUseCase(
                userRepository: UserRepository(
                    localUserDataSource: UserDefaultsUserDataSource(),
                    remoteUserDataSource: RemoteUserDataSource(provider: Provider.default)
                ),
                studyRepository: studyRepository
            ),
            joinStudyUseCase: JoinStudyUseCase(
                studyRepository: studyRepository
            )
        )
        
        viewModel.navigation
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .chatRoom(let id):
                    self?.showChatRoom(id: id)
                case .profile(let type):
                    self?.showProfile(type: type)
                case .back:
                    self?.finish.onNext(.back)
                }
            })
            .disposed(by: disposeBag)
        
        let viewController = StudyDetailViewController(viewModel: viewModel)
        pushTabbar(viewController, animated: true)
    }
    
    // MARK: - 채팅방
    
    func showChatRoom(id: String) {
        let chatRoom = ChatRoomCoordinator(id: id, navigationController)
        coordinator(to: chatRoom)
            .subscribe(onNext: {
                switch $0 {
                case .back: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 사용자 프로필
    
    func showProfile(type: ProfileType) {
        let profile = ProfileCoordinator(type: type, hideTabbar: true, navigationController)
        coordinator(to: profile)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
