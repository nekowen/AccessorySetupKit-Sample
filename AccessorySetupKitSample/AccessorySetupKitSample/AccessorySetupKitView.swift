import SwiftUI
import CoreBluetooth

struct AccessorySetupKitView: View {
    @StateObject private var viewModel: AccessorySetupKitViewModel = .init()
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Bluetooth: \(stateText(viewModel.bluetoothState))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.isScanning {
                    Label("Scanning", systemImage: "dot.radiowaves.left.and.right")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.blue)
                }
            }

            HStack(spacing: 12) {
                Button("Start Pairing") {
                    Task {
                        try await viewModel.startPairing()
                    }
                }
                Button("Delete Pairing") {
                    viewModel.deletePairing()
                }
                Button("Migrate Pairing") {
                    Task {
                        try await viewModel.migratePairing()
                    }
                }
            }
            
            if let error = viewModel.lastError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            TextField("テキスト入力エリア", text: $inputText)
                .font(.system(size: 25))
                .autocapitalization(.none)
                .padding(.top, 32)
        }
        .onAppear {
            viewModel.activateSession()
        }
        .padding()
    }

    private func stateText(_ state: CBManagerState) -> String {
        switch state {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered Off"
        case .poweredOn: return "Powered On"
        @unknown default: return "Unknown"
        }
    }
}

#Preview {
    AccessorySetupKitView()
}
