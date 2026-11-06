public func squareNumbers(_ numbers: [Int]) -> [Int] {
    return numbers.map { $0 * $0 }
}

public func filterEvenNumbers(_ numbers: [Int]) -> [Int] {
    return numbers.filter { $0 % 2 == 0}
}

public func sumOfNumbers(_ numbers: [Int]) -> Int {
    numbers.reduce(0) { $0 + $1 }
}
