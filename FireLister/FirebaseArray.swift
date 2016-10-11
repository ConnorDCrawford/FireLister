import Firebase

class FirebaseArray<Model: FirebaseModel>: NSObject, Collection {
    
    typealias Index = Int
    typealias SortOrderBlock = (Model, Model) -> ComparisonResult
    
    /**
     * The delegate object that array changes are surfaced to, which conforms to the
     * [FirebaseArrayDelegate Protocol](FirebaseArrayDelegate).
     */
    weak var delegate: FirebaseArrayDelegate?
    
    /**
     * The query on a Firebase reference that provides data to populate the instance of FirebaseArray.
     */
    private(set) var query: FIRDatabaseQuery
    
    /**
     * The predicate by which the snapshots are filtered. If predicate is nil, the array reflects all
     * results from the Firebase Query or Reference.
     */
    private(set) var predicate: NSPredicate?
    
    private var sortOrderBlock: SortOrderBlock?
    
    /**
     * Intitalizes FirebaseArray with a standard Firebase reference.
     * @param ref The Firebase reference which provides data to FirebaseArray
     * @return The instance of FirebaseArray
     */
    convenience init(ref: FIRDatabaseReference) {
        self.init(query: ref, sortDescriptors: nil, predicate: nil)
    }
    
    /**
     * Intitalizes FirebaseArray with a Firebase query (FIRDatabaseQuery).
     * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
     * @return The instance of FirebaseArray
     */
    convenience init(query: FIRDatabaseQuery) {
        self.init(query: query, sortDescriptors: nil, predicate: nil)
    }
    
    /**
     * Initializes FirebaseArray with a standard Firebase reference and an array of NSSortDescriptors.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting behavior.
     * @param ref The Firebase reference which provides data to FirebaseArray
     * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
     * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
     * @return The instance of FirebaseArray
     */
    convenience init(ref: FIRDatabaseReference, sortDescriptors: [NSSortDescriptor]?) {
        self.init(query: ref, sortDescriptors: sortDescriptors, predicate: nil)
    }
    
    /**
     * Initializes FirebaseArray with a Firebase query (FIRDatabaseQuery) and an array of NSSortDescriptors.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting behavior than an FIRDatabaseQuery can provide.
     * It is recommended that you use FIRDatabaseQuery to filter, rather than sort, for use with this initializer.
     * E.G. query only objects that have false for their hidden flag, then sort using Sort Descriptors.
     * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
     * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
     * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
     * @return The instance of FirebaseArray
     */
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?) {
        self.init(query: query, sortDescriptors: sortDescriptors, predicate: nil)
    }
    
    /**
     * Initializes FirebaseArray with a standard Firebase reference and an NSPredicate.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting or filtering behavior than an FIRDatabaseQuery can provide.
     * @param ref The Firebase reference which provides data to FirebaseArray
     * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
     * reflects all results from the Firebase Query or Reference.
     * @return The instance of FirebaseArray
     */
    convenience init(ref: FIRDatabaseReference, predicate: NSPredicate?) {
        self.init(query: ref, sortDescriptors: nil, predicate: predicate)
    }
    
    /**
     * Initializes FirebaseArray with a Firebase query (FIRDatabaseQuery) and an NSPredicate.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting or filtering behavior than an FIRDatabaseQuery can provide.
     * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
     * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
     * reflects all results from the Firebase Query or Reference.
     * @return The instance of FirebaseArray
     */
    convenience init(query: FIRDatabaseQuery, predicate: NSPredicate?) {
        self.init(query: query, sortDescriptors: nil, predicate: predicate)
    }
    
    /**
     * Initializes FirebaseArray with a standard Firebase reference, an array of NSSortDescriptors, and an
     * NSPredicate.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting or filtering behavior than an FIRDatabaseQuery can provide.
     * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
     * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
     * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
     * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
     * reflects all results from the Firebase Query or Reference.
     * @return The instance of FirebaseArray
     */
    convenience init(ref: FIRDatabaseReference, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?) {
        self.init(query: ref, sortDescriptors: sortDescriptors, predicate: predicate)
    }
    
    /**
     * Initializes FirebaseArray with a Firebase query (FIRDatabaseQuery), an array of NSSortDescriptors, and an
     * NSPredicate.
     * Use this if you would like the array to be sorted after being received from the server, or if
     * you would like more complex sorting or filtering behavior than an FIRDatabaseQuery can provide.
     * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
     * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
     * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
     * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
     * reflects all results from the Firebase Query or Reference.
     * @return The instance of FirebaseArray
     */
    init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?) {
        self.query = query
        self.predicate = predicate
        super.init()
        self.setSortOrder(with: sortDescriptors)
        self.initListeners()
    }
    
    init(query: FIRDatabaseQuery, predicate: NSPredicate?, sortOrderBlock: SortOrderBlock?) {
        self.query = query
        self.predicate = predicate
        self.sortOrderBlock = sortOrderBlock
        super.init()
        self.initListeners()
    }
    
    deinit {
        for handle in self.observerHandles {
            self.query.removeObserver(withHandle: handle)
        }
    }
    
    // MARK: - Private API methods
    
    private var models = [Model]()
    private var isInitialized = false
    private lazy var observerHandles = [UInt]()
    private lazy var keys = Set<String>()
    
    private func initListeners() {
        
        let cancelHandler: (Error)->Void = { (error: Error) in
            self.delegate?.cancelledWithError?(error: error)
        }
        
        let valueHandler = { (snapshot: FIRDataSnapshot) in
            for childSnap in snapshot.children.allObjects {
                guard let childSnap = childSnap as? FIRDataSnapshot else { break }
                guard let object = Model(snapshot: childSnap) else { break }
                let index = self.insertionIndex(of: object)
                self.models.insert(object, at: index)
                self.keys.insert(object.key)
            }
            self.delegate?.initialized?(objects: self.models)
            self.isInitialized = true
        }
        
        let addHandler = { (snapshot: FIRDataSnapshot) in
            guard self.isInitialized, let object = Model(snapshot: snapshot), !self.keys.contains(snapshot.key) else { return }
            let index = self.insertionIndex(of: object)
            self.models.insert(object, at: index)
            self.delegate?.childAdded?(object: object, at: index)
        }
        
        let changeHandler = { (snapshot: FIRDataSnapshot) in
            if let index = self.indexForKey(snapshot.key) {
                guard let object = Model(snapshot: snapshot) else { return }
                self.models.remove(at: index)
                let insertionIndex = self.insertionIndex(of: object)
                self.models.insert(object, at: insertionIndex)
                
                self.delegate?.childChanged?(object: object, at: index)
                if index != insertionIndex {
                    self.delegate?.childMoved?(object: object, from: index, to: insertionIndex)
                }
            }
        }
        
        let removeHandler = { (snapshot: FIRDataSnapshot) in
            if let index = self.indexForKey(snapshot.key) {
                let object = self.models[index]
                self.models.remove(at: index)
                self.delegate?.childRemoved?(object: object, at: index)
            }
        }
        
        let moveHandler = { (snapshot: FIRDataSnapshot) in
            if let oldIndex = self.indexForKey(snapshot.key) {
                self.models.remove(at: oldIndex)
                
                guard let object = Model(snapshot: snapshot) else { return }
                let newIndex = self.insertionIndex(of: object)
                self.models.insert(object, at: newIndex)
                self.delegate?.childMoved?(object: object, from: oldIndex, to: newIndex)
            }
        }
        
        self.query.observeSingleEvent(of: .value, with: valueHandler, withCancel: cancelHandler)
        let added = self.query.observe(.childAdded, with: addHandler, withCancel: cancelHandler)
        let changed = self.query.observe(.childChanged, with: changeHandler, withCancel: cancelHandler)
        let removed = self.query.observe(.childRemoved, with: removeHandler, withCancel: cancelHandler)
        let moved = self.query.observe(.childMoved, with: moveHandler, withCancel: cancelHandler)
        
        self.observerHandles = [added, changed, removed, moved]
    }
    
    func compare(model: Model, with aModel: Model) -> ComparisonResult {
        let m1 = model
        let m2 = aModel
        
        if let sortOrderBlock = self.sortOrderBlock {
            return sortOrderBlock(m1, m2)
        }
        return m1.key.compare(m2.key)
    }
    
    private func indexForKey(_ key: String) -> Int? {
        return self.models.index(where: { (snapshot) -> Bool in
            if snapshot.key == key {
                return true
            }
            return false
        })
    }
    
    private func insertionIndex(of object: Model) -> Int {
        return self.models.insertionIndex(of: object) { (s1, s2) -> Bool in
            return self.compare(model: s1, with: s2) == .orderedAscending
        }
    }
    
    // MARK: - Public API methods
    
    func setSortOrder(with sortOrderBlock: SortOrderBlock?) {
        self.sortOrderBlock = sortOrderBlock
        if let sortOrderBlock = sortOrderBlock {
            self.models.sort(by: { (m1, m2) -> Bool in
                return sortOrderBlock(m1, m2) == .orderedAscending
            })
        } else {
            self.models.sort(by: { (m1, m2) -> Bool in
                return m1.key.compare(m2.key) == .orderedAscending
            })
        }
        self.delegate?.changedSortOrder?(objects: self.models)
    }
    
    func setSortOrder(with sortDescriptors: [NSSortDescriptor]?) {
        var sortOrderBlock: SortOrderBlock?
        if let sortDescriptors = sortDescriptors, !sortDescriptors.isEmpty {
            sortOrderBlock = { (m1: Model, m2: Model) -> ComparisonResult in
                if m1.key == m2.key {
                    return .orderedSame
                }
                
                var result = ComparisonResult.orderedSame
                for sortDescriptor in sortDescriptors {
                    result = sortDescriptor.compare(m1, to: m2)
                    if (result != .orderedSame) {
                        break
                    }
                }
                return result
                
            }
        }
        
        self.setSortOrder(with: sortOrderBlock)
    }
    
    /**
     * Returns an object at a specific index in the FirebaseArray.
     * @param index The index of the item to retrieve
     * @return The object at the given index
     */
    func object(at index: Int) -> Model {
        return self.models[index]
    }
    
    /**
     * Returns a Firebase reference for an object at a specific index in the FirebaseArray.
     * @param index The index of the item to retrieve a reference for
     * @return A Firebase reference for the object at the given index
     */
    func ref(for index: Int) -> FIRDatabaseReference {
        return self.models[index].ref
    }
    
    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return count
    }
    
    /**
     * Returns the count of objects in the FirebaseArray.
     * @return The count of objects in the FirebaseArray
     */
    var count: Int {
        return self.models.count
    }
    
    subscript(index: Int) -> Model {
        return self.models[index]
    }
    
    subscript(key: String) -> Model? {
        if let index = self.indexForKey(key) {
            return self.models[index]
        }
        return nil
    }
    
    func index(after i: Index) -> Index {
        return i + 1
    }
    
}
