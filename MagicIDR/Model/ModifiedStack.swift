//
//  ModifiedStack.swift
//  MagicIDR
//
//  Created by 박재우 on 2/6/24.
//

import Foundation

struct ModifiedStack<T> {

    private var elements = [T]()

    var top: T? {
        elements.last
    }

    var count: Int {
        elements.count
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    mutating func push(_ element: T) {
        elements.append(element)
    }

    mutating func pop() {
        elements.removeLast()
    }

    mutating func remove(at index: Int) {
        elements.remove(at: index)
    }

    func element(at index: Int) -> T? {
        guard 0 <= index && index < count else {
            return nil
        }

        return elements[index]
    }
}
