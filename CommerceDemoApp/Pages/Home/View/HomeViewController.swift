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
    
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = UIColor(rgb: 0xF7F7F7)
        $0.collectionViewLayout = layout
        $0.register(SwipeBannerCollectionViewCell.self, forCellWithReuseIdentifier: SwipeBannerCollectionViewCell.identifier)
        $0.register(GoodsListCollectionViewCell.self, forCellWithReuseIdentifier: GoodsListCollectionViewCell.identifier)
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
        collectionView.rx.contentOffset
            .filter { [weak self] point in
                guard let self = self,
                      self.state?.isPaging == false
                else { return false }

                let offset = point.y
                let collectionViewContentSizeY = self.collectionView.contentSize.height
                let paginationY = collectionViewContentSizeY * 0.4
                return offset > collectionViewContentSizeY - paginationY
            }
            .map { _ in HomeReactor.Action.pagingGoods }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func bindState(_ reactor: HomeReactor) {
        reactor.pulse(\.$insertGoodsItems)
            .filter{ !$0.isEmpty }
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] rows in
                let insertIndexPaths: [IndexPath] = rows.map {IndexPath(row: $0, section: HomeSectionType.goodsList.rawValue)}
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.insertItems(at: insertIndexPaths)
                })
            })
            .disposed(by: disposeBag)
        
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

extension HomeViewController: UICollectionViewDelegate {
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
}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = HomeSectionType(rawValue: indexPath.section)
        
        switch sectionType {
        case .banner:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwipeBannerCollectionViewCell.identifier, for: indexPath) as? SwipeBannerCollectionViewCell else { return UICollectionViewCell() }
            cell.cellModel = state?.bannerList
            return cell
            
        case .goodsList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsListCollectionViewCell.identifier, for: indexPath) as? GoodsListCollectionViewCell else { return UICollectionViewCell() }
            cell.cellModel = state?.goodsList[indexPath.item]
            cell.likeBtn.isHidden = false
            cell.likeBtn.rx.tap
                .asDriver()
                .drive(onNext: {[weak self] in
                    guard let item = cell.cellModel else { return }
                    let willLike = !cell.likeBtn.isSelected
                    cell.likeBtn.isSelected = willLike
                    cell.likeBtn.tintColor = willLike ? .appColor(.rosePink) : .white
                    
                    let goodsType = (indexPath.item, item)
                    if willLike {
                        self?.reactor?.action.onNext(.addLikeGood(goodsType))
                    } else {
                        self?.reactor?.action.onNext(.removeLikeGood(goodsType))
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
