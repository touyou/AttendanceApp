//
//  UserDefaults+PropertyWrapper.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import Foundation

// ref: https://qiita.com/ryotapoi/items/2f861f734a4d48aad487

// MARK: - UserDefaultCompatible Protocol

protocol UserDefaultCompatible {
    init?(userDefaultObject: Any)
    func toUserDefaultObject() -> Any?
}

extension UserDefaults {

    func value<Value: UserDefaultCompatible>(type: Value.Type = Value.self, forKey key: String, default defaultValue: Value) -> Value {
        guard let object = object(forKey: key) else { return defaultValue }
        return Value(userDefaultObject: object) ?? defaultValue
    }

    func setValue<Value: UserDefaultCompatible>(_ value: Value, forKey key: String) {
        set(value.toUserDefaultObject(), forKey: key)
    }
}

extension String: UserDefaultCompatible {
    init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }

    func toUserDefaultObject() -> Any? {
        self
    }
}

extension Bool: UserDefaultCompatible {
    init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }

    func toUserDefaultObject() -> Any? {
        self
    }
}

extension URL: UserDefaultCompatible {
    init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Data else { return nil }
        guard let url = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(userDefaultObject) as? URL else { return nil }
        self = url
    }

    func toUserDefaultObject() -> Any? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Date: UserDefaultCompatible {
    init?(userDefaultObject: Any) {
        guard let userDefaultObject = userDefaultObject as? Self else { return nil }
        self = userDefaultObject
    }

    func toUserDefaultObject() -> Any? {
        self
    }
}

extension Optional: UserDefaultCompatible where Wrapped: UserDefaultCompatible {
    init?(userDefaultObject: Any) {
        self = Wrapped(userDefaultObject: userDefaultObject)
    }

    func toUserDefaultObject() -> Any? {
        flatMap { $0.toUserDefaultObject() }
    }
}

// MARK: - Property Wrapper

@propertyWrapper
struct UserDefault<Value: UserDefaultCompatible> {
    private let key: String
    private let defaultValue: Value

    private let userDefaults = UserDefaults(suiteName: "group.dev.touyou.GpAttendance.WidgetExtension")!

    init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            userDefaults.value(type: Value.self, forKey: key, default: defaultValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: key)
        }
    }
}
