// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift

//extension ThreadConfined: TokenObject {
//
//}

extension Realm {
    func writeAsync<T>(obj: T, errorHandler: @escaping ((_ error: Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) where T : ThreadConfined, T : TokenObject {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                } catch {
                    errorHandler(error)
                }
            }
        }
    }
}
