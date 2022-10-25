import Foundation

enum Retry<Failure: Error>: Error {
    case retry(Failure)
    case doNotRetry(Failure)
}

struct Operation<A> {
    private let runCont: (@escaping (A) -> Void) -> Void

    init(_ run: @escaping (@escaping (A) -> Void) -> Void) {
        self.runCont = run
    }

    static func pure(_ a: A) -> Operation<A> {
        return Operation<A> { cb in cb(a) }
    }

    func map<B>(_ f: @escaping (A) -> B) -> Operation<B> {
        return Operation<B> { cb in
            self.runCont { a in cb(f(a)) }
        }
    }

    func flatMap<B>(_ f: @escaping (A) -> Operation<B>) -> Operation<B> {
        return Operation<B> { cb in
            self.runCont { a in f(a).runCont(cb) }
        }
    }

    func run(_ action: @escaping (A) -> Void) {
        runCont(action)
    }
}

struct OperationResult<Success, Failure: Error> {
    private let cont: Operation<Result<Success, Failure>>

    init(_ cont: Operation<Result<Success, Failure>>) {
        self.cont = cont
    }

    init(_ f: @escaping (@escaping (Result<Success, Failure>) -> Void) -> Void) {
        self.init(Operation(f))
    }

    static func success(_ s: Success) -> OperationResult<Success, Failure> {
        return OperationResult<Success, Failure>(Operation.pure(.success(s)))
    }

    static func failure(_ f: Failure) -> OperationResult<Success, Failure> {
        return OperationResult<Success, Failure>(Operation.pure(.failure(f)))
    }

    static func pure(_ r: Result<Success, Failure>) -> OperationResult<Success, Failure> {
        return OperationResult<Success, Failure>(Operation.pure(r))
    }

    static func fromOptional(_ value: Success?, else: @autoclosure () -> Failure) -> OperationResult<Success, Failure> {
        if let value = value {
            return .success(value)
        } else {
            return .failure(`else`())
        }
    }

    static func retry(
        with delay: TimeInterval = 0,
        attempts: Int,
        operation: @escaping () -> OperationResult<Success, Retry<Failure>>
    ) -> OperationResult<Success, Failure> {
        return operation().recover(with: delay) {
            switch $0 {
            case .retry(let error):
                if attempts > 0 {
                    return retry(with: delay, attempts: attempts - 1, operation: operation)
                } else {
                    return .failure(error)
                }
            case .doNotRetry(let error):
                return .failure(error)
            }
        }
    }

    func map<NewSuccess>(_ f: @escaping (Success) -> NewSuccess) -> OperationResult<NewSuccess, Failure> {
        return OperationResult<NewSuccess, Failure>(cont.map { $0.map(f) })
    }

    func flatMap<NewSuccess>(_ f: @escaping (Success) -> OperationResult<NewSuccess, Failure>) -> OperationResult<NewSuccess, Failure> {
        return OperationResult<NewSuccess, Failure>(cont.flatMap { result in
            Operation { cb in
                result.onSuccess { f($0).cont.run(cb) }
                    .onFailure { cb(.failure($0)) }
            }
        })
    }

    func mapError<NewFailure>(_ f: @escaping (Failure) -> NewFailure) -> OperationResult<Success, NewFailure> {
        return OperationResult<Success, NewFailure>(cont.map { $0.mapError(f) })
    }

    func recover<NewFailure>(with delay: TimeInterval = 0, _ f: @escaping (Failure) -> OperationResult<Success, NewFailure>) -> OperationResult<Success, NewFailure> {
        return OperationResult<Success, NewFailure>(cont.flatMap { result in
            Operation { cb in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    result.onSuccess {
                        cb(.success($0))

                    }.onFailure { f($0).cont.run(cb) }
                }
            }
        })
    }

    func onSuccess(_ action: @escaping (Success) -> Void) -> OperationResult<Success, Failure> {
        return self.flatMap {
            action($0)
            return .success($0)
        }
    }

    func run(_ action: @escaping (Result<Success, Failure>) -> Void) {
        return cont.run(action)
    }

    static func map2<A, B>(_ ra: OperationResult<A, Failure>, _ rb: OperationResult<B, Failure>, f: @escaping(A, B) -> Success) -> OperationResult<Success, Failure> {
        return ra.flatMap { a in rb.map { b in f(a, b) } }
    }

    static func flatMap2<A, B>(_ ra: OperationResult<A, Failure>, _ rb: OperationResult<B, Failure>, f: @escaping(A, B) -> OperationResult<Success, Failure>) -> OperationResult<Success, Failure> {
        return ra.flatMap { a in rb.flatMap { b in f(a, b) } }
    }
}

public typealias Action1<R> = (R) -> Void
public extension Result {

    @discardableResult
    func also(_ action: @escaping Action1<Success>) -> Result {
        if case let .success(v) = self {
            action(v)
        }
        return self
    }

    @discardableResult
    func onSuccess(_ action: @escaping Action1<Success>) -> Result {
        return also(action)
    }

    @discardableResult
    func onFailure(_ action: @escaping Action1<Failure>) -> Result {
        if case let .failure(v) = self {
            action(v)
        }
        return self
    }
}

public extension Result {
    static func sequence(_ array: [Result]) -> Result<[Success], Failure> {
        var result = Result<[Success], Failure>.success([])
        for item in array {
            result = result.flatMap { item.map([Success].concat($0)) }
        }
        return result
    }
}

extension Array {
    static func concat<V>(_ array: [V]) -> (V) -> [V] {
        return { element in
            var copy = [V](array)
            copy.append(element)
            return copy
        }
    }
}
