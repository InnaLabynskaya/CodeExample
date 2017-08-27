
final class ProjectCollectionListFacade {
    private let projectListLoader: ProjectListLoader
    private let collectionListLoader: CollectionListLoader
    private let loadingGroup = DispatchGroup()

    fileprivate var allProjects: [Project]?
    fileprivate var allCollections: [Collection]?
    private(set) var error: Error?
    
    private(set) var isInitialized = false

    init(projectListLoader: ProjectListLoader, collectionListLoader: CollectionListLoader) {
        self.projectListLoader = projectListLoader
        self.collectionListLoader = collectionListLoader
        loadData()
    }
    
    private func loadData() {
        load { success in
            if success {
                dLog("Loaded")
            } else {
                dLog("Loading failed")
            }
        }
    }

    func load(completion: ((Bool) -> Void)? = nil) {
        loadingGroup.enter()
        let projectRequest = ProjectListRequest()
        projectListLoader.fetchProjectList(request: projectRequest) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let projects):
                strongSelf.allProjects = projects
            case .failure(let error):
                strongSelf.error = error
                dLog("Couldn't fetch projects \(error.localizedDescription)")
            }
            strongSelf.loadingGroup.leave()
        }
        
        loadingGroup.enter()
        let collectionRequest = CollectionListRequest()
        collectionListLoader.fetchCollectionList(request: collectionRequest) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let collections):
                strongSelf.allCollections = collections
            case .failure(let error):
                strongSelf.error = error
                dLog("Couldn't fetch collections \(error.localizedDescription)")
            }
            strongSelf.loadingGroup.leave()
        }
        
        loadingGroup.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isInitialized = (strongSelf.allProjects != nil) && (strongSelf.allCollections != nil)
            completion?(strongSelf.isInitialized)
        }
    }
}

extension ProjectCollectionListFacade {
    
    func getProjectList() -> [Project]? {
        return allProjects
    }
    
    func getCollectionList() -> [Collection]? {
        return allCollections
    }
    
}
