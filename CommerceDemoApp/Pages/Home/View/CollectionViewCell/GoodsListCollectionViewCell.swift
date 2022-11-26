//
//  GoodsListCollectionViewCell.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit
import RxSwift
import SnapKit
import Then

class GoodsListCollectionViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    
    var goodsImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    var discountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor.appColor(.rosePink)
        $0.textAlignment = .left
    }
    
    var priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor.appColor(.textPrimary)
        $0.textAlignment = .left
    }
    
    var nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.appColor(.textSecondary)
        $0.numberOfLines = 0
    }
    
    var newLabel = UILabel().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appColor(.textSecondary).cgColor
        $0.layer.cornerRadius = 3
        $0.font = .systemFont(ofSize: 10, weight: .regular)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        $0.text = "NEW"
    }
    
    var sellCountLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.textSecondary)
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    var likeBtn = UIButton().then{
        $0.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        $0.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .selected)
        $0.tintColor = UIColor.white
    }
    
    var cellModel: GoodsItemModel? {
        didSet {
            guard let model = cellModel else { return }
            let isDiscount = (model.discountPercent > 0)
            self.goodsImage.kf.setImage(with: URL(string: model.image))
            self.discountLabel.isHidden = !isDiscount
            self.discountLabel.text = "\(model.discountPercent)%"
            self.priceLabel.text = model.price.toDecimal()
            self.nameLabel.text = model.name
            self.sellCountLabel.isHidden = !(model.sellCount >= 10)
            self.sellCountLabel.text = model.sellCount.toDecimal() + "개 구매중"
            self.newLabel.isHidden = !model.isNew
            self.likeBtn.isHidden = !model.likeAvailable
            self.likeBtn.isSelected = model.isLike
            
            self.updatePriceLayout(isDiscount: isDiscount)
            self.updateNewBadgeLayout(isNew: model.isNew)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

extension GoodsListCollectionViewCell {
    func configureLayout() {
        self.addSubview(goodsImage)
        self.addSubview(likeBtn)
        self.addSubview(discountLabel)
        self.addSubview(priceLabel)
        self.addSubview(nameLabel)
        self.addSubview(newLabel)
        self.addSubview(sellCountLabel)
        
        goodsImage.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(23)
            $0.width.height.equalTo(100)
        }
    
        likeBtn.snp.makeConstraints {
            $0.top.trailing.equalTo(goodsImage).inset(8)
            $0.width.equalTo(30)
            $0.height.equalTo(28)
        }
        
        discountLabel.snp.makeConstraints {
            $0.left.equalTo(goodsImage.snp.right).offset(10)
            $0.height.equalTo(23)
            $0.top.equalTo(goodsImage)
        }

        priceLabel.snp.makeConstraints {
            $0.left.equalTo(discountLabel.snp.right).offset(3)
            $0.top.height.equalTo(discountLabel)
            $0.right.lessThanOrEqualTo(self).offset(-15)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(discountLabel)
            $0.trailing.lessThanOrEqualTo(self).offset(-15)
            $0.top.equalTo(discountLabel.snp.bottom).offset(6)
            $0.height.greaterThanOrEqualTo(0)
        }
        
        newLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(30)
            $0.leading.equalTo(discountLabel)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(35)
            $0.height.equalTo(20)
        }
        
        sellCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(newLabel)
            $0.leading.equalTo(newLabel.snp.trailing).offset(5)
            $0.trailing.lessThanOrEqualTo(self).offset(-15)
            $0.height.equalTo(20)
        }
    }
    
    func updatePriceLayout(isDiscount: Bool) {
        priceLabel.snp.updateConstraints {
            $0.left.equalTo(discountLabel.snp.right).offset(isDiscount ? 3 : 0)
        }
    }
    
    func updateNewBadgeLayout(isNew: Bool) {
        newLabel.snp.updateConstraints {
            $0.width.equalTo(isNew ? 35 : 0)
        }
        
        sellCountLabel.snp.updateConstraints {
            $0.leading.equalTo(newLabel.snp.trailing).offset(isNew ? 5 : 0)
        }
    }
}
