import Foundation

extension Array {
    func insertionIndex(of element: Element, _ isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var min = 0
        var max = self.count - 1
        while min <= max {
            let mid = (min + max)/2
            if isOrderedBefore(self[mid], element) {
                min = mid + 1
            } else if isOrderedBefore(element, self[mid]) {
                max = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return min // not found, would be inserted at position min
    }
}
