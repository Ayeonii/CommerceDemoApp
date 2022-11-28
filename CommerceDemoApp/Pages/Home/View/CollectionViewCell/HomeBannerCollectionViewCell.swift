//
//  HomeBannerCollectionViewCell.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then

class SwipeBannerCollectionViewCell: UICollectionViewCell {
    static let identifier = "SwipeBannerCollectionViewCell"
    
    var disposeBag = DisposeBag()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        let deviceWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: deviceWidth, height: deviceWidth * (300/375))
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        $0.delegate = self
        $0.collectionViewLayout = layout
        $0.isPagingEnabled = true
        $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        $0.showsHorizontalScrollIndicator = false
    }
    
    var countView = UIView().then {
        $0.backgroundColor = .blue
        $0.clipsToBounds = true
        $0.backgroundColor = .gray.withAlphaComponent(0.5)
    }
    
    var countLabel = UILabel().then{
        $0.font = UIFont.systemFont(ofSize: 12.0)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private var currentIndex : Int = 1
    private var bannerItems = BehaviorRelay<[BannerItemModel]>(value : [])
    var cellModel: [BannerItemModel]? {
        didSet {
            guard let model = cellModel else { return }
            countLabel.text = "\(currentIndex)/\(model.count)"
            bannerItems.accept(model)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayout()
        bindView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.countView.layer.cornerRadius = countView.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        bindView()
    }
    
    private func bindView() {
        bannerItems
            .observe(on: MainScheduler.instance)
            .bind(to : collectionView.rx.items(
                cellIdentifier: "CollectionViewCell",
                cellType: UICollectionViewCell.self)
            ) { indexPath, data, cell in
                let banner = UIImageView().then {
                    $0.clipsToBounds = true
                    $0.contentMode = .scaleAspectFill
                    $0.kf.setImage(with: URL(string: data.image), options: [.transition(.fade(0.3))])
                }
                
                cell.addSubview(banner)
                banner.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        self.addSubview(collectionView)
        self.addSubview(countView)
        countView.addSubview(countLabel)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        countView.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(50)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(5)
        }
    }
}

extension SwipeBannerCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerItems.value.count
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width)) + 1
        countLabel.text = "\(currentIndex)/\(cellModel?.count ?? 0)"
    }
}
