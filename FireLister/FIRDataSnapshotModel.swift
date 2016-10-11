import Firebase

class FIRDataSnapshotModel: FIRDataSnapshot, FirebaseModel {
    
    // Hidden variables for storing property values
    // Needed because Firebase made all values of FIRDataSnapshot immutable, so we must override
    private var innerValue: Any?
    private var innerChildrenCount: UInt
    private var innerRef: FIRDatabaseReference
    private var innerKey: String
    private var innerChildren: NSEnumerator
    private var innerPriority: Any?
    
    override var value: Any? {
        get {
            return innerValue
        }
    }
    
    override var childrenCount: UInt {
        get {
            return innerChildrenCount
        }
    }
    
    override var ref: FIRDatabaseReference {
        get {
            return innerRef
        }
    }
    
    override var key: String {
        get {
            return innerKey
        }
    }
    
    override var children: NSEnumerator {
        get {
            return innerChildren
        }
    }
    
    override var priority: Any? {
        get {
            return innerPriority
        }
    }
    
    required init?(snapshot: FIRDataSnapshot) {
        innerValue = snapshot.value
        innerChildrenCount = snapshot.childrenCount
        innerRef = snapshot.ref
        innerKey = snapshot.key
        innerChildren = snapshot.children
        innerPriority = snapshot.priority
        super.init()
    }
    
}
