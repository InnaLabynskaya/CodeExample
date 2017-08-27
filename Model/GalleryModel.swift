
enum GalleryModelStatus {
    case none
    case loading
    case success([Project], [Collection])
    case failure(Error)
    case empty
}

protocol GalleryModel: class {
    weak var output: GalleryModelOutput? { get set }
    func load()
}

protocol GalleryModelOutput: class {
    func didUpdate(status: GalleryModelStatus)
}
