import Foundation
import Combine
import CoreBluetooth
import AccessorySetupKit
import UIKit

struct DiscoveredPeripheral: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}

final class AccessorySetupKitViewModel: NSObject, ObservableObject {
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var devices: [DiscoveredPeripheral] = []
    @Published private(set) var connectedPeripheralID: UUID? = nil
    @Published private(set) var isConnecting: Bool = false
    @Published private(set) var lastError: String? = nil
    // MARK: - Published UI State
    @Published var sessionState: String = "inactive"

    private var central: CBCentralManager!
    private var discovered: [UUID: DiscoveredPeripheral] = [:]
    private var currentPeripheral: CBPeripheral? = nil

    private let serviceUUID = CBUUID(string: "1812")
    private var currentBluetoothIdentifier: UUID? = nil
    
    // MARK: - Accessory Setup
    private let session = ASAccessorySession()
    private var currentAccessory: ASAccessory?

    private func makeProductImage() -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: 96, weight: .regular)
        return UIImage(systemName: "antenna.radiowaves.left.and.right", withConfiguration: configuration)!
    }

    // MARK: - AccessorySession
    func activateSession() {
        session.activate(on: DispatchQueue.main) { [weak self] (event: ASAccessoryEvent) in
            guard let self else { return }

            switch event.eventType {
            case .activated:
                if let accessory = session.accessories.last {
                    // すでにセットアップ済みのアクセサリがあれば、先頭のアクセサリに対して接続処理を行う
                    self.currentAccessory = accessory
                    self.handleAccessoryAdded(accessory)
                }
            case .accessoryAdded:
                self.currentAccessory = event.accessory
            case .accessoryRemoved:
                self.currentAccessory = nil
            case .pickerDidDismiss:
                guard let currentAccessory else { return }
                handleAccessoryAdded(currentAccessory)
                self.currentAccessory = nil
            case .migrationComplete:
                print("Migration complete")
            case .pickerSetupFailed:
                // 何らかの理由によりセットアップに失敗(PINコードの不一致など)
                self.sessionState = "pickerSetupFailed"
            default:
                self.sessionState = "event: \(event.eventType)"
            }
            
            print("Event: \(self.sessionState)")
        }
    }
    
    private func handleAccessoryAdded(_ accessory: ASAccessory) {
        // Bluetooth IDを取得
        guard let bluetoothIdentifier = accessory.bluetoothIdentifier else { return }
        
        self.currentBluetoothIdentifier = bluetoothIdentifier
        if central == nil {
            central = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    private func bleConnect(_ p: CBPeripheral) {
        currentPeripheral = p
        central?.connect(p, options: nil)
    }
    

    // MARK: - Pairing controls
    func startPairing() async throws {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = serviceUUID
        descriptor.supportedOptions = [.bluetoothPairingLE, .bluetoothHID]
        
        let displayName = "BLE-Demo"
        let productImage = makeProductImage()
        let displayItem = ASPickerDisplayItem(
            name: displayName,
            productImage: productImage,
            descriptor: descriptor
        )
        
        try await session.showPicker(for: [displayItem])
    }

    func migratePairing() async throws {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.supportedOptions = [.bluetoothPairingLE, .bluetoothHID]
        
        let displayName = "BLE-Demo"
        let productImage = makeProductImage()
        let displayItem = ASMigrationDisplayItem(
            name: displayName,
            productImage: productImage,
            descriptor: descriptor
        )
        
        // AccessorySetupKit に移行したい Peripheral Bluetooth Identifier を指定する
        let bluetoothIdentifier = UUID(uuidString: "PLEASE-SPECIFIC-PERIPHERAL-BLUETOOTH-IDENTIFIER")!
        displayItem.peripheralIdentifier = bluetoothIdentifier
        
        try await session.showPicker(for: [displayItem])
    }

    func deletePairing() {
        guard let accessory = session.accessories.first else {
            print("No paired accessories.")
            return
        }
        session.removeAccessory(accessory) { [weak self] err in
            if let err { print("Failed to remove accessory: \(err)") }
            self?.teardownBLE()
        }
    }

    private func teardownBLE() {
        if let p = currentPeripheral {
            central?.cancelPeripheralConnection(p)
        }
        currentPeripheral = nil
    }
}

extension AccessorySetupKitViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        if bluetoothState == .poweredOn, let currentBluetoothIdentifier {
            // Bluetooth IDからCBPeripheralを取得する
            let peripherals = central.retrievePeripherals(withIdentifiers: [currentBluetoothIdentifier])
            // 該当のPeripheralが存在していれば接続する
            if let peripheral = peripherals.first {
                bleConnect(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(peripheral.identifier)
    }
}
