//
//  ParticipantCell.swift
//  Mogakco
//
//  Created by 이주훈 on 2022/11/15.
//

import UIKit

import RxSwift
import Alamofire
import SnapKit
import Then

final class ParticipantCell: UICollectionViewCell, Identifiable {
    
    static let size = CGSize(width: 110, height: 130)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layout()
    }
    
    private let imageView = RoundProfileImageView(50)
    let disposeBag = DisposeBag()
    
    private let userNameLabel = UILabel().then {
        $0.font = .mogakcoFont.mediumBold
        $0.textColor = .mogakcoColor.typographyPrimary
        $0.text = "default User name"
    }
    
    private let userDescriptionLabel = UILabel().then {
        $0.font = MogakcoFontFamily.SFProDisplay.semibold.font(size: 14)
        $0.textColor = .mogakcoColor.typographySecondary
        $0.text = "default user desctiption"
    }
    
    private func layout() {
        layoutView()
        layoutImageView()
        layoutNameLabel()
        layoutDescriptionLabel()
    }
    
    private func layoutView() {
        backgroundColor = .mogakcoColor.backgroundDefault
        layer.cornerRadius = 10
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.mogakcoColor.borderDefault?.cgColor
        
        clipsToBounds = false
    }
    
    private func layoutImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(15)
//            $0.width.height.equalTo(50)
        }
    }
    
    private func layoutNameLabel() {
        addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(15)
        }
    }
    
    private func layoutDescriptionLabel() {
        addSubview(userDescriptionLabel)
        userDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(userNameLabel.snp.bottom).offset(5)
        }
    }
    
    func setInfo(user: User?) {
        if let imageURLString = user?.profileImageURLString {
            imageView.load(url: imageURLString, disposeBag: disposeBag)
        } else {
            imageView.setPhoto(Image.profileDefault)
        }
        userNameLabel.text = user?.name ?? "None"
        userDescriptionLabel.text = user?.introduce ?? "None"
    }
}
