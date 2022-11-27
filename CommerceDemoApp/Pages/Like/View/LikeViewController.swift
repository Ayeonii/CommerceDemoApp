//
//  LikeViewController.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class LikeViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    var state: LikeReactor.State? {
        return self.reactor?.currentState
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        
        $0.delegate = self
        $0.backgroundColor = UIColor(rgb: 0xF7F7F7)
        $0.collectionViewLayout = layout
        $0.register(GoodsListCollectionViewCell.self, forCellWithReuseIdentifier: GoodsListCollectionViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "좋아요"
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.getLikeGoodsList)
    }
    
    func bind(reactor: LikeReactor) {
        self.bindState(reactor)
    }
    
    private func bindState(_ reactor: LikeReactor) {
        reactor.state
            .filter{ $0.shouldReload }
            .observe(on: MainScheduler.instance)
            .bind(onNext: {[weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$goodsList)
            .observe(on: MainScheduler.instance)
            .bind(to : collectionView.rx.items(
                cellIdentifier: GoodsListCollectionViewCell.identifier,
                cellType: GoodsListCollectionViewCell.self)
            ) { indexPath, item, cell in
                cell.cellModel = item
                cell.likeBtn.isHidden = true
            }
            .disposed(by: disposeBag)
    }
}

extension LikeViewController {
    func configureLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints{ make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension LikeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width
        let estimateHeight = 600.0
        let sizingCell = GoodsListCollectionViewCell(frame: CGRect(x: 0, y: 0, width: deviceWidth, height: estimateHeight))
        sizingCell.cellModel = state?.goodsList[indexPath.item]
        sizingCell.layoutIfNeeded()
        
        let estimatedSize = sizingCell.systemLayoutSizeFitting(CGSize(width: deviceWidth, height: estimateHeight))
        return CGSize(width: deviceWidth, height: estimatedSize.height)
    }
}
