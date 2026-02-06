import Foundation

extension Array {
    func appending(_ element: Element) -> [Element] {
        var result = self
        result.append(element)
        return result
    }

    func appending(contentsOf elements: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: elements)
        return result
    }
}
