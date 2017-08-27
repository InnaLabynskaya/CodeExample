
import Foundation

class GalleryCollectionsModelImpl {
    
    weak var output: GalleryModelOutput?
    let loader: CollectionListLoader
    
    var isLoaded: Bool  {
        switch status {
        case .success:
            return true
        default:
            return false
        }
    }
    
    fileprivate var status: GalleryModelStatus = .none {
        didSet {
            notifyObserver()
        }
    }
    
    
    init(with loader: CollectionListLoader) {
        self.loader = loader
    }
    
    fileprivate func notifyObserver() {
        output?.didUpdate(status: status)
    }
    
}

extension GalleryCollectionsModelImpl: GalleryModel {
    func load() {
        switch status {
        case .none: fallthrough
        case .failure:
            break
        default:
            notifyObserver()
            return
        }
        status = .loading
        loader.fetchCollectionList(request: CollectionListRequest()) {
            [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let collections):
                if collections.count == 0 {
                    strongSelf.status = .empty
                } else {
                    strongSelf.status = .success([], collections)
                }
            case .failure(let error):
                strongSelf.status = .failure(error)
            }
        }
    }
}
