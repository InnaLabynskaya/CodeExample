
import Foundation
import UIKit
import XLPagerTabStrip
import DTCollectionViewManager

class GalleryViewController: UIViewController, IndicatorInfoProvider, ActivityViewPresenter {
    
    //Injectable
    var presenter: GalleryPresenter!
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    lazy var itemInfo: IndicatorInfo = {
        return IndicatorInfo(title: self.title ?? "")
    }()
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        configureActivityService()
        presenter.viewLoaded()
    }
    
    private func configureActivityService() {
        let config = ActivityServiceConfigFactory.makeConfig(for: .productList)
        activityService.setup(with: self, config: config) { [unowned self] in
            self.presenter.onRetryTap()
        }
    }

}

extension GalleryViewController: GalleryView, DTCollectionViewManageable {
    
    func prepareCollectionView() {
        manager.startManaging(withDelegate: self)
        manager.register(GalleryCell.self)
        manager.didSelect(GalleryCell.self) { [weak self] cell, model, indexPath in
            switch model.collectionType {
            case .project:
                self?.presenter.showProjectCards(with: model.id)
            case .collection:
                self?.presenter.showCollectionProducts(with: model.id)
            }
        }
        collectionView?.collectionViewLayout = LayoutsFactory.layoutForGallery()
    }
    
    func didUpdate(status: GalleryModelStatus) {
        switch status {
        case .none:
            break
        case .loading:
            activityService.state = .loading
        case .failure:
            activityService.state = .failure
        case .success(let projects, let collections):
            activityService.state = .hidden
            showList(with: projects, collections: collections)
        case .empty:
            activityService.state = .empty
        }
    }
    
    func showList(with projects: [Project], collections: [Collection]) {
        let projectModels = projects
            .map { GalleryCellModel(with: $0) }
        let collectionModels = collections.map { GalleryCellModel(with: $0) }
        manager.memoryStorage.setItems(projectModels + collectionModels)
        collectionView?.reloadData()
    }
}
