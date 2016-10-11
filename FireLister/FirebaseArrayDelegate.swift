import Firebase

@objc protocol FirebaseArrayDelegate {
    
    @objc optional func initialized(objects: [FirebaseModel])
    @objc optional func childAdded(object: FirebaseModel, at index: Int)
    @objc optional func childChanged(object: FirebaseModel, at index: Int)
    @objc optional func childRemoved(object: FirebaseModel, at index: Int)
    @objc optional func childMoved(object: FirebaseModel, from oldIndex: Int, to newIndex: Int)
    @objc optional func changedSortOrder(objects: [FirebaseModel])
    @objc optional func cancelledWithError(error: Error)
    
}
