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

//import UIKit
//import FirebaseDatabase
//
//class PaginatedFirebaseArray<Model : FirebaseModel>: FirebaseArray<Model> {
//    
//    var pageSize: UInt
//    var startValue: Any?
//    var endValue: Any?
//    var paginatedQuery: FIRDatabaseQuery
//    lazy var pageEndValues = [Any?]()
//    
//    public init(query: FIRDatabaseQuery, sortOrderBlock: SortOrderBlock?, filterBlock: FilterBlock?, pageSize: UInt, startValue: Any?, endValue: Any?) {
//        self.pageSize = pageSize
//        self.startValue = startValue
//        self.endValue = endValue
//        paginatedQuery = query.queryLimited(toFirst: pageSize)
//        super.init(query: query, sortOrderBlock: sortOrderBlock, filterBlock: filterBlock)
//    }
//    
//    func updateQuery(for pageNumber: Int) {
//        paginatedQuery = query.queryStarting(atValue: pageEndValues[pageNumber]).queryLimited(toFirst: pageSize)
//    }
//    
//}
