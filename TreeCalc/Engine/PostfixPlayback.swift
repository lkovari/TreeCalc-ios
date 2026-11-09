import Foundation

struct PostfixPlayback: Equatable {
    var index: Int?
    var running = false

    mutating func toggle(count: Int, stepByStep: Bool) {
        if count <= 0 {
            return
        }
        if running {
            running = false
            return
        }
        if stepByStep {
            step(count: count)
            return
        }
        if let index, index < count - 1 {
            running = true
            return
        }
        index = 0
        running = true
    }

    mutating func tick(count: Int) {
        guard running, count > 0 else { return }
        if let index, index + 1 < count {
            self.index = index + 1
        } else {
            running = false
        }
    }

    mutating func select(_ index: Int) {
        running = false
        if self.index == index {
            self.index = nil
        } else {
            self.index = index
        }
    }

    mutating func step(count: Int) {
        if count <= 0 {
            return
        }
        guard let current = index else {
            index = 0
            running = false
            return
        }
        if current + 1 < count {
            index = current + 1
        }
        running = false
    }

    mutating func stop() {
        self = PostfixPlayback()
    }
}
