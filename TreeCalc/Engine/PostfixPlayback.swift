import Foundation

struct PostfixPlayback: Equatable {
    var index: Int?
    var running = false

    mutating func toggle(count: Int, reduceMotion: Bool) {
        if running {
            running = false
            return
        }
        guard count > 0 else { return }
        if reduceMotion {
            if let index, index + 1 < count {
                self.index = index + 1
            } else {
                self.index = 0
            }
            running = false
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
}
