import Firebase

protocol FirebaseArrayDelegate: class {
    
    func beginUpdates()
    func endUpdates()
    func initialized<Model : FirebaseModel>(children: [Model])
    func added<Model : FirebaseModel>(child: Model, at index: Int)
    func changed<Model : FirebaseModel>(child: Model, at index: Int)
    func removed<Model : FirebaseModel>(child: Model, at index: Int)
    func moved<Model : FirebaseModel>(child: Model, from oldIndex: Int, to newIndex: Int)
    func changedSortOrder<Model : FirebaseModel>(of children: [Model])
    func cancelled(with error: Error)
    
}

extension FirebaseArrayDelegate {
    
    func beginUpdates() {}
    func endUpdates() {}
    func initialized<Model : FirebaseModel>(children: [Model]) {}
    func added<Model : FirebaseModel>(child: Model, at index: Int) {}
    func changed<Model : FirebaseModel>(child: Model, at index: Int) {}
    func removed<Model : FirebaseModel>(child: Model, at index: Int) {}
    func moved<Model : FirebaseModel>(child: Model, from oldIndex: Int, to newIndex: Int) {}
    func changedSortOrder<Model : FirebaseModel>(of children: [Model]) {}
    func cancelled(with error: Error) {}
    
}
