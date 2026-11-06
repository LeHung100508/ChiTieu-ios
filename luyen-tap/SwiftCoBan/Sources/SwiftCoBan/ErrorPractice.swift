public enum MathError: Error, Equatable {
    case divisionByZero
    case negativeValue
}

public func divide(_ a: Int, by b: Int) throws(MathError) -> Int {
    guard b != 0 else {
        throw .divisionByZero
    }
    
    return a / b
}
public func safeSquareRoot(_ number: Double) -> Result<Double, MathError> {
    guard number >= 0 else {
        return .failure(.negativeValue)
    }
    return .success(number.squareRoot())
}
