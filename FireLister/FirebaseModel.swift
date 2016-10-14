import Firebase

@objc protocol FirebaseModel: AnyObject {
    
    init?(snapshot: FIRDataSnapshot)
    var key: String { get }
    var ref: FIRDatabaseReference { get }
    @objc optional var priority: Any? { get }
    @objc optional func push(_ completionHandler: ((Error?)->Void)?)
    
}
