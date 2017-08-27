
import Foundation

class GalleryModelImpl {
    
    weak var output: GalleryModelOutput?
    let facade: ProjectCollectionListFacade
    
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

    
    init(with facade: ProjectCollectionListFacade) {
        self.facade = facade
    }
    
    fileprivate func notifyObserver() {
        output?.didUpdate(status: status)
    }
    
}

extension GalleryModelImpl: GalleryModel {
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
        facade.load { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                let projects = strongSelf.facade.getProjectList()
                let collections = strongSelf.facade.getCollectionList()
                if projects?.count == 0 && collections?.count == 0 {
                    strongSelf.status = .empty
                } else {
                    strongSelf.status = .success(projects!, collections!)
                }
            } else if let error = strongSelf.facade.error {
                strongSelf.status = .failure(error)
            } else {
                strongSelf.status = .none
            }
            
        }
    }
}
