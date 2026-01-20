import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorPersistentAccountPlugin)
public class CapacitorPersistentAccountPlugin: CAPPlugin, CAPBridgedPlugin {
    private let pluginVersion: String = "8.0.10"
    public let identifier = "CapacitorPersistentAccountPlugin"
    public let jsName = "CapacitorPersistentAccount"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "readAccount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveAccount", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPluginVersion", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = CapacitorPersistentAccount()

    @objc func readAccount(_ call: CAPPluginCall) {
        do {
            let result = try implementation.readAccount()
            call.resolve([
                "data": result.data ?? NSNull(),
                "accountName": result.accountName ?? NSNull()
            ])
        } catch {
            call.reject("Failed to read account: \(error.localizedDescription)")
        }
    }

    @objc func saveAccount(_ call: CAPPluginCall) {
        do {
            let accountName = call.getString("accountName")
            try implementation.saveAccount(call.getObject("data"), accountName: accountName)
            call.resolve()
        } catch {
            call.reject("Failed to save account: \(error.localizedDescription)")
        }
    }

    @objc func getPluginVersion(_ call: CAPPluginCall) {
        call.resolve(["version": self.pluginVersion])
    }

}
