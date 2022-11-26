//
//  HomeViewController.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Then

enum HomeSectionType: Int, CaseIterable {
    case banner = 0
    case goodsList = 1
}

class HomeViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    var state: HomeReactor.State? {
        return self.reactor?.currentState
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        
        $0.backgroundColor = UIColor(rgb: 0xF7F7F7)
        $0.delegate = self
        $0.dataSource = self
        $0.collectionViewLayout = layout
        $0.register(SwipeBannerCollectionViewCell.self, forCellWithReuseIdentifier: "SwipeBannerCollectionViewCell")
        $0.register(GoodsListCollectionViewCell.self, forCellWithReuseIdentifier: "GoodsListCollectionViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "홈"
        configureLayout()
    }
    
    func bind(reactor: HomeReactor) {
        self.bindAction(reactor)
        self.bindState(reactor)
        reactor.action.onNext(.initialFetch)
    }
    
    private func bindAction(_ reactor: HomeReactor) {
        
    }
    
    private func bindState(_ reactor: HomeReactor) {
        reactor.state
            .filter{ $0.shouldReload }
            .observe(on: MainScheduler.instance)
            .bind(onNext: {[weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    func configureLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = HomeSectionType(rawValue: section)
        
        switch sectionType {
        case .goodsList:
            return state?.goodsList.count ?? 0
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = HomeSectionType(rawValue: indexPath.section)
        
        switch sectionType {
        case .banner:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwipeBannerCollectionViewCell", for: indexPath) as? SwipeBannerCollectionViewCell else { return UICollectionViewCell() }
            cell.cellModel = state?.bannerList
            return cell
            
        case .goodsList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoodsListCollectionViewCell", for: indexPath) as? GoodsListCollectionViewCell else { return UICollectionViewCell() }
            cell.cellModel = state?.goodsList[indexPath.item]
            
            cell.likeBtn.rx.tap
                .asDriver()
                .drive(onNext: {[weak self] in
                    guard let item = cell.cellModel else { return }
                    let willLike = !cell.likeBtn.isSelected
                    cell.likeBtn.isSelected = willLike
                    cell.likeBtn.tintColor = willLike ? .appColor(.rosePink) : .white
                    if willLike {
                        self?.reactor?.action.onNext(.addLikeGood(item))
                    } else {
                        self?.reactor?.action.onNext(.removeLikeGood(item))
                    }
                })
                .disposed(by: cell.disposeBag)
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = HomeSectionType(rawValue: indexPath.section)
        let deviceWidth = UIScreen.main.bounds.width
        
        switch sectionType {
        case .banner:
            return CGSize(width: deviceWidth, height: deviceWidth * (300/375))
            
        default:
            let estimateHeight = 600.0
            let sizingCell = GoodsListCollectionViewCell(frame: CGRect(x: 0, y: 0, width: deviceWidth, height: estimateHeight))
            sizingCell.cellModel = state?.goodsList[indexPath.item]
            sizingCell.layoutIfNeeded()
            
            let estimatedSize = sizingCell.systemLayoutSizeFitting(CGSize(width: deviceWidth, height: estimateHeight))
            return CGSize(width: deviceWidth, height: estimatedSize.height)
        }
    }
}
