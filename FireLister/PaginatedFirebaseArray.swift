//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import FirebaseDatabase

class PaginatedFirebaseArray<T : FirebaseModel>: FirebaseArray<T> {
    
    var pageSize: UInt
    var startValue: Any?
    var endValue: Any?
    var sortKey: String?
    var paginatedQuery: FIRDatabaseQuery
    var lastLoadedObject: T?
    var isLoaded = false
    
    lazy var pageEndValues = [Any?]()
    var pageNumber = 0
    
    public init(query: FIRDatabaseQuery, sortOrderBlock: SortOrderBlock?, filterBlock: FilterBlock?, pageSize: UInt, startValue: Any?, endValue: Any?) {
        self.pageSize = pageSize
        self.startValue = startValue
        self.endValue = endValue
        paginatedQuery = query.queryLimited(toFirst: pageSize)
        super.init(query: query, sortOrderBlock: sortOrderBlock, filterBlock: filterBlock)
        initListeners(for: paginatedQuery)
    }
    
    override func initListeners(for query: FIRDatabaseQuery) {
        
        // Do not init listeners for orignal query
        if query == self.query {
            return
        }
        
        let cancelHandler: (Error)->Void = { (error: Error) in
            self.delegate?.cancelled(with: error)
        }
        
        let valueHandler = { (snapshot: FIRDataSnapshot) in
            let children = snapshot.children.allObjects
            if UInt(children.count) < self.pageSize - 1 {
                self.isLoaded = true
            }
            
            for (i, childSnap) in children.enumerated() {
                
                // After the first page, the first element of the new page will be a duplicate of the
                // last element of the previous page due to how FIRDatabaseQuery works.
                // Therefore, we must ignore it.
                guard i != 0 || self.pageNumber == 0,
                    let childSnap = childSnap as? FIRDataSnapshot,
                    let model = T(snapshot: childSnap)
                    else { continue }
                
                let index = self.insertionIndex(of: model)
                self.keys.insert(model.key)
                
                // Check if result should be filtered
                if let filterBlock = self.filterBlock, !filterBlock(model) {
                    self.hiddenModels[model.key] = model
                } else {
                    self.models.insert(model, at: index)
                }
                
                // Check if child is the last element in the page
                if !self.isLoaded && i == children.count - 1 {
                    self.lastLoadedObject = model
                    
                    guard let values = childSnap.value as? [String : Any] else { break }
                    if let sortKey = self.sortKey {
                        self.pageEndValues.append(values[sortKey] as? String)
                    } else {
                        self.pageEndValues.append(childSnap.key)
                    }
                }
            }
            self.delegate?.initialized()
        }
        
        let addHandler = { (snapshot: FIRDataSnapshot) in
            guard self.pageNumber < self.pageEndValues.count, let model = T(snapshot: snapshot) else { return }
            
            // Check if result should be filtered
            if let filterBlock = self.filterBlock, !filterBlock(model) {
                self.hiddenModels[model.key] = model
                return
            }
            
            if !self.keys.contains(model.key) {
                let index = self.insertionIndex(of: model)
                self.models.insert(model, at: index)
                self.delegate?.added(child: model, at: index)
            }
            
        }
        
        let removeHandler = { (snapshot: FIRDataSnapshot) in
            if let index = self.index(of: snapshot.key) {
                let model = self.models[index]
                self.keys.remove(model.key)
                self.models.remove(at: index)
                self.hiddenModels.removeValue(forKey: model.key)
                self.delegate?.removed(child: model, at: index)
            }
        }
        
        let changeHandler = { (snapshot: FIRDataSnapshot) in
            let index = self.index(of: snapshot.key)
            guard let model = T(snapshot: snapshot) else { return }
            
            if let filterBlock = self.filterBlock {
                let shouldFilterModel = !filterBlock(model)
                
                // Check if result should be filtered, remove from models and put in hiddenModels if so
                if shouldFilterModel {
                    self.hiddenModels[model.key] = model
                    
                    if let index = index {
                        self.models.remove(at: index)
                        self.keys.remove(model.key)
                        self.delegate?.removed(child: model, at: index)
                    }
                    return
                } else if self.hiddenModels[model.key] != nil {
                    // Model is currently hidden, but now should not be. Put in models and show.
                    let index = self.add(hiddenModel: model)
                    self.delegate?.added(child: model, at: index)
                }
            }
            
            if let index = index {
                let insertionIndex = self.sortOrderBlock == nil ? index : self.insertionIndex(of: model)
                self.models.remove(at: index)
                self.models.insert(model, at: insertionIndex)
                self.delegate?.changed(child: model, at: index)
                
                if self.sortOrderBlock != nil && index != insertionIndex {
                    self.delegate?.moved(child: model, from: index, to: insertionIndex)
                }
                
            }
            
        }
        
        let moveHandler = { (snapshot: FIRDataSnapshot) in
            if let oldIndex = self.index(of: snapshot.key), let model = T(snapshot: snapshot) {
                self.models.remove(at: oldIndex)
                let newIndex = self.insertionIndex(of: model)
                self.models.insert(model, at: newIndex)
                self.delegate?.moved(child: model, from: oldIndex, to: newIndex)
            }
        }
        
        query.observeSingleEvent(of: .value, with: valueHandler, withCancel: cancelHandler)
        let added = query.observe(.childAdded, with: addHandler, withCancel: cancelHandler)
        let changed = query.observe(.childChanged, with: changeHandler, withCancel: cancelHandler)
        let removed = query.observe(.childRemoved, with: removeHandler, withCancel: cancelHandler)
        let moved = query.observe(.childMoved, with: moveHandler, withCancel: cancelHandler)
        
        observerHandles.append(contentsOf: [added, changed, removed, moved])
    }
    
    open func loadNextPage() {
        if !isLoaded {
            paginatedQuery = query.queryStarting(atValue: pageEndValues[pageNumber]).queryLimited(toFirst: pageSize)
            initListeners(for: paginatedQuery)
            pageNumber += 1
        }
    }
    
}
