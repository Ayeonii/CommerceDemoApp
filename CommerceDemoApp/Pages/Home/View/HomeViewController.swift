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

class HomeViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    var state: HomeReactor.State? {
        return self.reactor?.currentState
    }
    
    let refreshControl = UIRefreshControl()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout()).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = UIColor(rgb: 0xF7F7F7)
        $0.register(SwipeBannerCollectionViewCell.self, forCellWithReuseIdentifier: SwipeBannerCollectionViewCell.identifier)
        $0.register(GoodsListCollectionViewCell.self, forCellWithReuseIdentifier: GoodsListCollectionViewCell.identifier)
        $0.refreshControl = self.refreshControl
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
        refreshControl.rx.controlEvent(.valueChanged)
            .delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .map { _ in HomeReactor.Action.initialFetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.errorResult }
            .asDriver { _ in .never() }
            .drive(onNext: { apiError in
                print("에러발생", apiError)
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
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int,
                                                      layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionType = HomeSectionType(rawValue: sectionIndex)
            switch sectionType {
            case .banner:
                return self?.generateBannerLayout()
            default:
                return GoodsLayout.generateListLayout()
            }
        }
    }
    
    func generateBannerLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let deviceWidth = UIScreen.main.bounds.width
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(deviceWidth), heightDimension: .absolute(deviceWidth * (300/375)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
    
    func generateGoodsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width), heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.interGroupSpacing = 2
        
        return section
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
                    cell.setLike(willSelect: willLike)
                    
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
