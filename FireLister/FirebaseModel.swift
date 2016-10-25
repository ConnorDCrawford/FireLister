import Firebase

protocol FirebaseModel: AnyObject, Equatable {
    
    init?(snapshot: FIRDataSnapshot)
    var key: String { get }
    var ref: FIRDatabaseReference { get }
    
}

func ==<T:FirebaseModel> (lhs: T, rhs: T) -> Bool {
    return lhs.ref == rhs.ref
}
