// SPDX-License-Identifier: GPL-3.0-or-later
// Author: naveenkrdy
// Copyright (C) 2026 Vorssaint

import Foundation
import Security

/// Stores the user's own Google Cloud Translation API key. A credential like
/// this has no business in UserDefaults (plist, world-readable within the
/// sandbox), so this is the app's first Keychain usage - scoped to this one
/// generic-password item rather than built as a general-purpose store.
enum LiveTranslationKeyStore {
    private static let service = "com.vorssaint.utils.live-translation"
    private static let account = "google-api-key"

    static func read() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(_ key: String) {
        guard !key.isEmpty else {
            delete()
            return
        }
        let data = Data(key.utf8)
        if read() != nil {
            let update: [String: Any] = [kSecValueData as String: data]
            SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        } else {
            var add = baseQuery
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            SecItemAdd(add as CFDictionary, nil)
        }
    }

    static func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private static var baseQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }
}
