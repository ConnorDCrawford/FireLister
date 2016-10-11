import Firebase

class FirebaseDataSource<Model: FirebaseModel>: NSObject, FirebaseArrayDelegate {
    
    var array: FirebaseArray<Model>
    var cancelBlock: ((Error)->Void)?
    
    init(array: FirebaseArray<Model>) {
        self.array = array
        super.init()
        
        self.array.delegate = self
    }
    
    // MARK: - API methods
    
    var count: Int {
        return self.array.count
    }
    
    func object(at indexPath: IndexPath) -> Model? {
        if indexPath.row < self.array.count {
            return self.array[indexPath.row]
        }
        return nil
    }
    
    func ref(for indexPath: IndexPath) -> FIRDatabaseReference? {
        if indexPath.row < self.array.count {
            return self.array.ref(for: indexPath.row)
        }
        return nil
    }
    
    func cancel(with block: ((Error)->Void)?) {
        self.cancelBlock = block
    }
    
    // MARK: - FirebaseArrayDelegate methods
    
    func cancelledWithError(error: Error) {
        cancelBlock?(error)
    }
}
