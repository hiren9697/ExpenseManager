//
//  File.swift
//  ExpenseFeature
//
//  Created by Hirenkumar Fadadu on 21/04/26.
//

import Testing
import Storage

class Person {
    let name: String
    weak var apartment: Apartment?
    
    init(name: String) {
        self.name = name
        print("\(name) is initialized")
    }
    
    // This will never print because of the leak!
    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    var tenant: Person?
    
    init(unit: String) {
        self.unit = unit
        print("Apartment \(unit) is initialized")
    }
    
    // This will never print because of the leak!
    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}

@Suite("Expense Repository Tests")
struct ExpenseRepositoryTests {
    @Test("Load delivers no expenses on an empty database")
    func load_deliversEmptyOnEmptyDatabase() async throws {
        makeSUT({ person, apartment in
        })
    }
    
    
    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation, _ completion: (Person, Apartment) -> Void) {
        withMemoryLeakTracking(sourceLocation: sourceLocation, testBody: { tracker in
            let john: Person = Person(name: "John Appleseed")
            let unit4A: Apartment = Apartment(unit: "4A")
            
            john.apartment = unit4A
            unit4A.tenant = john
            
            tracker(john)
            tracker(unit4A)
            
            completion(john, unit4A)
        })
    }
}

