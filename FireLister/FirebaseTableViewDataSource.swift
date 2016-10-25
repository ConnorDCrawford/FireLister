import Firebase

class FirebaseTableViewDataSource<Model: FirebaseModel>: FirebaseDataSource<Model>, UITableViewDataSource {
    
    /**
     * The reuse identifier for cells in the UITableView.
     */
    var reuseIdentifier: String
    
    /**
     * The UITableView instance that operations (inserts, removals, moves, etc.) are
     * performed against.
     */
    var tableView: UITableView?
    
    /**
     * The callback to populate a subclass of UITableViewCell with an object
     * provided by the datasource.
     */
    var populateCell: ((UITableViewCell, Model)->Void)?
    
    var populateFooter: ((_ section: Int, _ sectionValue: NSObject?)->String?)?
    
    var sectionNameBlock: ((Model) -> String?)? {
        didSet {
            if self.sectionNameBlock != nil {
                self.updateSections()
            } else {
                self.sections.removeAll()
                self.sectionNames.removeAll()
            }
            self.tableView?.reloadData()
        }
    }
    
    private lazy var sections = [String : [Model]]()
    private lazy var sectionNames = [String]()
    
    // TODO: Add convenience initializers, documentation
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, filterBlock: FirebaseArray<Model>.FilterBlock?, cellClass: AnyClass?, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, filterBlock: filterBlock)
        tableView?.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, filterBlock: FirebaseArray<Model>.FilterBlock?, prototypeReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, filterBlock: filterBlock)
        self.init(array: array, reuseIdentifier: prototypeReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, filterBlock: FirebaseArray<Model>.FilterBlock?, nibNamed nibName: String, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, filterBlock: filterBlock)
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, filterBlock: FirebaseArray<Model>.FilterBlock?, cellClass: AnyClass?, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, filterBlock: filterBlock)
        tableView?.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, filterBlock: FirebaseArray<Model>.FilterBlock?, prototypeReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, filterBlock: filterBlock)
        self.init(array: array, reuseIdentifier: prototypeReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, filterBlock: FirebaseArray<Model>.FilterBlock?, nibNamed nibName: String, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, filterBlock: filterBlock)
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, predicate: NSPredicate?, cellClass: AnyClass?, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, predicate: predicate)
        tableView?.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, predicate: NSPredicate?, prototypeReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, predicate: predicate)
        self.init(array: array, reuseIdentifier: prototypeReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortOrderBlock: FirebaseArray<Model>.SortOrderBlock?, predicate: NSPredicate?, nibNamed nibName: String, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortOrderBlock: sortOrderBlock, predicate: predicate)
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?, cellClass: AnyClass?, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, predicate: predicate)
        tableView?.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?, prototypeReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, predicate: predicate)
        self.init(array: array, reuseIdentifier: prototypeReuseIdentifier, tableView: tableView)
    }
    
    convenience init(query: FIRDatabaseQuery, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?, nibNamed nibName: String, cellReuseIdentifier: String, tableView: UITableView?) {
        let array = FirebaseArray<Model>(query: query, sortDescriptors: sortDescriptors, predicate: predicate)
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        self.init(array: array, reuseIdentifier: cellReuseIdentifier, tableView: tableView)
    }
    
    init(array: FirebaseArray<Model>, reuseIdentifier: String, tableView: UITableView?) {
        self.reuseIdentifier = reuseIdentifier
        super.init(array: array)
        self.tableView = tableView
    }
    
    // MARK: - FirebaseArrayDelegate methods
    
    override func beginUpdates() {
        tableView?.beginUpdates()
    }
    
    override func endUpdates() {
        tableView?.endUpdates()
    }
    
    override func initialized<T : FirebaseModel>(children: [T]) {
        tableView?.reloadData()
    }
    
    override func added<T : FirebaseModel>(child: T, at index: Int) {
        guard let child = child as? Model else { return }
        if let sectionNameBlock = self.sectionNameBlock {
            // tableView is sectioned
            let sectionName = sectionNameBlock(child) ?? ""
            if var insertionSection = self.sections[sectionName] {
                // Section exists, insert snapshot in correct index
                let index = insertionSection.insertionIndex(of: child, { (s1, s2) -> Bool in
                    return self.array.compare(model: s1, with: s2) == .orderedAscending
                })
                insertionSection.insert(child, at: index)
                self.sections[sectionName] = insertionSection
                
                let sectionIndex = self.sectionNames.index(of: sectionName)!
                let indexPath = IndexPath(row: index, section: sectionIndex)
                self.tableView?.insertRows(at: [indexPath], with: .automatic)
            } else {
                // Section does not exist, create new section
                var sectionIndex: Int!
                self.sections[sectionName] = [child]
                if index == 0 {
                    sectionIndex = 0
                    self.sectionNames.insert(sectionName, at: 0)
                } else {
                    sectionIndex = self.indexPath(of: self.array[index - 1].key)!.section + 1
                    self.sectionNames.insert(sectionName, at: sectionIndex)
                }
                self.tableView?.insertSections([sectionIndex], with: .automatic)
            }
        } else {
            // tableView is not sectioned
            if self.tableView?.numberOfSections == 0 {
                self.tableView?.insertSections([0], with: .automatic)
            } else {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView?.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    override func changed<T : FirebaseModel>(child: T, at index: Int) {
        guard let child = child as? Model else { return }
        if let sectionNameBlock = self.sectionNameBlock {
            // tableView is sectioned
            let sectionName = sectionNameBlock(child) ?? ""
            if var section = self.sections[sectionName] {
                // Section exists, find index of changed snapshot
                
                let index = section.index(where: { (snap) -> Bool in
                    return snap.key == child.key
                })!
                section[index] = child
                self.sections[sectionName] = section
                
                let sectionIndex = self.sectionNames.index(of: sectionName)!
                let indexPath = IndexPath(row: index, section: sectionIndex)
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        } else {
            // tableView is not sectioned
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func removed<T : FirebaseModel>(child: T, at index: Int) {
        guard let child = child as? Model else { return }
        if let sectionNameBlock = self.sectionNameBlock {
            // tableView is sectioned
            let sectionName = sectionNameBlock(child) ?? ""
            if var section = self.sections[sectionName] {
                // Section exists, find index of removed snapshot
                let index = section.index(where: { (snap) -> Bool in
                    return snap.key == child.key
                })!
                section.remove(at: index)
                self.sections[sectionName] = section
                
                let sectionIndex = self.sectionNames.index(of: sectionName)!
                if section.isEmpty {
                    self.sectionNames.remove(at: sectionIndex)
                    self.sections.removeValue(forKey: sectionName)
                    self.tableView?.deleteSections([sectionIndex], with: .automatic)
                } else {
                    let indexPath = IndexPath(row: index, section: sectionIndex)
                    self.tableView?.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        } else {
            // tableView is not sectioned
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func moved<T : FirebaseModel>(child: T, from oldIndex: Int, to newIndex: Int) {
        guard let child = child as? Model else { return }
        if let sectionNameBlock = self.sectionNameBlock {
            // tableView is sectioned
            let sectionName = sectionNameBlock(child) ?? ""
            if var section = self.sections[sectionName] {
                // Section exists, insert snapshot in correct index
                let oldIndex = section.index(where: { (model) -> Bool in
                    return model.key == child.key
                })!
                section.remove(at: oldIndex)
                let newIndex = section.insertionIndex(of: child, { (m1, m2) -> Bool in
                    return self.array.compare(model: m1, with: m2) == .orderedAscending
                })
                section.insert(child, at: newIndex)
                self.sections[sectionName] = section
                
                let sectionIndex = self.sectionNames.index(of: sectionName)!
                let oldIndexPath = IndexPath(row: oldIndex, section: sectionIndex), newIndexPath = IndexPath(row: newIndex, section: sectionIndex)
                self.tableView?.moveRow(at: oldIndexPath, to: newIndexPath)
            } else {
                // Section does not exist, create new section
                self.sections[sectionName] = [child]
                let sectionIndex = self.sectionNames.count
                self.sectionNames.append(sectionName)
                self.tableView?.insertSections([sectionIndex], with: .automatic)
            }
        } else {
            // tableView is not sectioned
            let oldIndexPath = IndexPath(row: oldIndex, section: 0), newIndexPath =  IndexPath(row: newIndex, section: 0)
            self.tableView?.moveRow(at: oldIndexPath, to: newIndexPath)
        }
    }
    
    override func changedSortOrder<T : FirebaseModel>(of children: [T]) {
        self.updateSections()
        self.tableView?.reloadData()
    }
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        var object: Model!
        
        if self.sectionNames.isEmpty {
            object = self.array[indexPath.row]
        } else {
            let sectionValue = self.sectionNames[indexPath.section]
            let section = self.sections[sectionValue]
            object = section![indexPath.row]
        }
        
        self.populateCell?(cell, object)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.sectionNameBlock != nil {
            return self.sectionNames[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self.sectionNameBlock != nil {
            return populateFooter?(section, self.sectionNames[section] as NSObject?)
        }
        return populateFooter?(section, nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionNameBlock == nil {
            return self.array.count
        }
        
        let sectionValue = self.sectionNames[section]
        if let section = self.sections[sectionValue] {
            return section.count
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.sectionNameBlock != nil {
            return self.sectionNames.count
        }
        return 1
    }
    
    // MARK: - Public API methods
    
    /**
     * Returns an object at a specific index in the FirebaseArray.
     * @param indexPath The index path of the item to retrieve
     * @return The object at the given index path
     */
    override func object(at indexPath: IndexPath) -> Model? {
        if self.sectionNameBlock != nil {
            let sectionValue = self.sectionNames[indexPath.section]
            let section = self.sections[sectionValue]!
            return section[indexPath.row]
        }
        return super.object(at: indexPath)
    }
    
    func indexPath(of key: String) -> IndexPath? {
        if self.sectionNameBlock != nil {
            for (value, section) in self.sections {
                for (index, item) in section.enumerated() {
                    if key == item.key {
                        let sectionIndex = self.sectionNames.index(of: value)!
                        return IndexPath(row: index, section: sectionIndex)
                    }
                }
            }
            return nil
        }
        guard let index = self.array.index(where: { (model: Model) -> Bool in
            return key == model.key
        })
            else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    /**
     * Returns a Firebase reference for an object at a specific index in the FirebaseArray.
     * @param indexPath The index path of the item to retrieve a reference for
     * @return A Firebase reference for the object at the given index path
     */
    override func ref(for indexPath: IndexPath) -> FIRDatabaseReference? {
        return self.object(at: indexPath)?.ref
    }
    
    func populateCell(with callback: ((UITableViewCell, Model)->Void)?) {
        self.populateCell = callback
    }
    
    func populateFooterTitle(with callback: ((_ section: Int, _ sectionValue: NSObject?)->String?)?) {
        self.populateFooter = callback
    }
    
    // MARK: - Private API methods
    
    private func updateSections() {
        self.sections.removeAll()
        self.sectionNames.removeAll()
        for object in self.array {
            let sectionName = self.sectionNameBlock?(object) ?? ""
            if self.sections[sectionName] != nil {
                self.sections[sectionName]!.append(object)
            } else {
                self.sections[sectionName] = [object]
                self.sectionNames.append(sectionName)
            }
        }
    }
    
}
