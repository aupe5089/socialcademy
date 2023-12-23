//
//  Lodable.swift
//  Socialcademy
//
//  Created by Austin Pearman on 12/21/23.
//

import Foundation

//This enum tracks the state of any items to be loaded into the app
enum Loadable<Value> {
    case loading
    case error(Error) //Error and Value as associated values
    case loaded(Value)
    
    //Computed property in enum
    //Could access like:
        //let loadableValue = Loadable.loading
        //let computedValue = loadableValue.value
    var value: Value? {
        get {
            //if the value is not nil (?) return the value
            if case let .loaded(value) = self {
                return value
            }
            return nil
        }
        set {
            //ensure the new value passed into the setter is not nil
                //Note that the type of value is optional
                //newValue is a variable name accessed through the setter
            guard let newValue = newValue else { return }
            self = .loaded(newValue)
        }
    }
}

extension Loadable where Value: RangeReplaceableCollection {
    static var empty: Loadable<Value> { .loaded(Value()) }
}

extension Loadable: Equatable where Value: Equatable {
    static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.error(error1), .error(error2)):
            return error1.localizedDescription == error2.localizedDescription
        case let (.loaded(value1), .loaded(value2)):
            return value1 == value2
        default:
            return false
        }
    }
}

#if DEBUG
extension Loadable {
    func simulate() async throws -> Value {
        switch self {
        case .loading:
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            fatalError("Timeout exceeded in loading case")
        case let .error(error):
            throw error
        case let .loaded(value):
            return value
        }
    }
    
    static var error: Loadable<Value> { .error(PreviewError()) }
    
    private struct PreviewError: LocalizedError {
        let errorDescription: String? = "Stuff"
    }
}
#endif
