import Foundation

extension Bundle {
    static var isSwizzled = false
    
    static func swizzleLocalization() {
        guard !isSwizzled else { return }
        isSwizzled = true
        
        let originalSelector = #selector(localizedString(forKey:value:table:))
        let swizzledSelector = #selector(gs_localizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc func gs_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // 1. Try to get from GhostStrings
        // We only intercept for the main bundle to avoid breaking system frameworks
        if self == Bundle.main {
            let gsValue = GhostStrings.shared.getSync(key)
            if gsValue != key {
                return gsValue
            }
        }
        
        // 2. Fallback to original implementation (which is now gs_localizedString due to exchange)
        return gs_localizedString(forKey: key, value: value, table: tableName)
    }
}

extension GhostStrings {
    /// Synchronous access for swizzling
    func getSync(_ key: String) -> String {
        return strings[key] ?? key
    }
}
