import Foundation
import Security

@objc public class CapacitorPersistentAccount: NSObject {
    private let service = "ee.forgr.capacitor_persistent_account"
    private let account = "CapacitorPersistentAccount"
    private let accountNameKey = "CapacitorPersistentAccount_AccountName"

    public func saveAccount(_ data: Any?, accountName: String?) throws {
        let jsonData: Data
        if let data = data {
            guard JSONSerialization.isValidJSONObject(data) else {
                throw NSError(domain: service, code: -1, userInfo: [NSLocalizedDescriptionKey: "Data is not JSON serializable"])
            }
            jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        } else {
            jsonData = Data()
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        // Remove existing item if any
        SecItemDelete(query as CFDictionary)

        var attrs: [String: Any] = query
        attrs[kSecValueData as String] = jsonData
        attrs[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(attrs as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain save failed: \(status)"])
        }

        // Save the account name separately
        try saveAccountName(accountName)
    }

    private func saveAccountName(_ accountName: String?) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountNameKey
        ]
        // Remove existing item if any
        SecItemDelete(query as CFDictionary)

        if let name = accountName {
            var attrs: [String: Any] = query
            attrs[kSecValueData as String] = name.data(using: .utf8)!
            attrs[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

            let status = SecItemAdd(attrs as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain save account name failed: \(status)"])
            }
        }
    }

    public func readAccount() throws -> (data: Any?, accountName: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return (nil, nil)
        }
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain read failed: \(status)"])
        }
        var data: Any?
        if let dataItem = item as? Data, !dataItem.isEmpty {
            data = try JSONSerialization.jsonObject(with: dataItem, options: [])
        }
        let accountName = try readAccountName()
        return (data, accountName)
    }

    private func readAccountName() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountNameKey,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain read account name failed: \(status)"])
        }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
