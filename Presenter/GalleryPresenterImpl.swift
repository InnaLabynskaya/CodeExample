
import Foundation

final class GalleryPresenterImpl {
    
    // Injected
    weak var view: GalleryView!
    var model: GalleryModel!
    var navigator: Navigator!
    
    init(view: GalleryView, model: GalleryModel) {
        self.view = view
        self.model = model
        self.model.output = self
        self.navigator = AppAssembly.current.navigator
    }
    
}

extension GalleryPresenterImpl: GalleryPresenter {
    func viewLoaded() {
        model.load()
    }
    
    func showProjectCards(with id: String) {
        navigator.navigateToProjectCardsScreen(with: id)
    }
    
    func showCollectionProducts(with id: String) {
        navigator.navigateToCollectionProductsScreen(with: id)
    }
    
    func onRetryTap() {
        model.load()
    }

}

extension GalleryPresenterImpl: GalleryModelOutput {
    func didUpdate(status: GalleryModelStatus) {
        view.didUpdate(status: status)
    }
}
