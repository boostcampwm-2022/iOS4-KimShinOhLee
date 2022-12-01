//
//  StudyDetailViewModel.swift
//  Mogakco
//
//  Created by 이주훈 on 2022/11/16.
//  Copyright © 2022 Mogakco. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

enum StudyDetailNavigation {
    case chatRoom(id: String)
    case profile(type: ProfileType)
    case back
}

final class StudyDetailViewModel: ViewModel {
    
    struct Input {
        let studyJoinButtonTapped: Observable<Void>
        let participantCellTapped: Observable<IndexPath>
        let backButtonTapped: Observable<Void>
    }
    
    struct Output {
        let studyDetail: Observable<Study>
        let languages: Driver<[Hashtag]>
        let participants: Driver<[User]>
    }
    
    var disposeBag = DisposeBag()
    var studyID: String = ""
    var studyDetailUseCase: StudyDetailUseCaseProtocol?
    var hashtagUseCase: HashtagUseCaseProtocol?
    var userUseCase: UserUseCaseProtocol?
    var joinStudyUseCase: JoinStudyUseCaseProtocol?
    
    let navigation = PublishSubject<StudyDetailNavigation>()
    var languages = BehaviorSubject<[Hashtag]>(value: [])
    var participants = BehaviorSubject<[User]>(value: [])
    var languageCount: Int { (try? languages.value().count) ?? 0 }
    var participantsCount: Int { (try? participants.value().count) ?? 0 }

    func transform(input: Input) -> Output {
        let studyDetailLoad = PublishSubject<Study>()
        let languages = BehaviorSubject<[Hashtag]>(value: [])
        let participants = BehaviorSubject<[User]>(value: [])
        
        studyDetailUseCase?.study(id: studyID)
            .bind(to: studyDetailLoad)
            .disposed(by: disposeBag)
        
        studyDetailLoad
            .withUnretained(self)
            .flatMap {
                $0.0.hashtagUseCase?.loadHashtagByString(
                    kind: .language,
                    tagTitle: $0.1.languages
                ) ?? .empty()
            }
            .bind(to: languages)
            .disposed(by: disposeBag)
        
        studyDetailLoad
            .withUnretained(self)
            .flatMap { $0.0.userUseCase?.users(ids: $0.1.userIDs) ?? .empty() }
            .bind(to: participants)
            .disposed(by: disposeBag)
        
        input.studyJoinButtonTapped
            .withUnretained(self)
            .flatMap { $0.0.joinStudyUseCase?.join(id: $0.0.studyID) ?? .empty() }
            .withUnretained(self)
            .subscribe(onNext: {
                $0.0.navigation.onNext(.chatRoom(id: $0.0.studyID))
            }, onError: { error in
                print("👀:", error) // TODO: 채팅방 인원이 다 찼을 때 예외처리
            })
            .disposed(by: disposeBag)
        
        input.participantCellTapped
            .map { $0.row }
            .subscribe { index in
                // TODO: 유저 선택 (코디네이터 리팩토링 후)
            }
        input.backButtonTapped
            .map { StudyDetailNavigation.back }
            .bind(to: navigation)
            .disposed(by: disposeBag)
        
        return Output(
            studyDetail: studyDetailLoad,
            languages: languages.asDriver(onErrorJustReturn: []),
            participants: participants.asDriver(onErrorJustReturn: [])
        )
    }
    
    func userSelect(index: Int) {
        // 사용자 선택되었을 때 내 프로필 보여주기: navigation.onNext(.current)
        // 사용자 선택되었을 때 다른 프로필 보여주기: navigation.onNext(.other(user))
    }
    
    func languaegCellInfo(index: Int) -> Hashtag? {
        return try? languages.value()[index]
    }
    
    func  participantCellInfo(index: Int) -> User? {
        return try? participants.value()[index]
    }
}
