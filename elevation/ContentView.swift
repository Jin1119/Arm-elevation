import SwiftUI
import SwiftData
import CoreBluetooth
import CoreMotion

struct ContentView: View {
    @ObservedObject var bluetooth: BluetoothConnect
    
    var body: some View {
        if let fileURL = BluetoothConnect.savedFileURL {
            Link("Open Saved File", destination: fileURL)
                .padding()
        }
        TabView {
            PolarView(bluetooth: bluetooth)
                .tabItem {
                    Label("Polar Sense", systemImage: "heart.fill")
                }

            iPhoneView(viewModel: ViewController())
                .tabItem {
                    Label("iPhone", systemImage: "phone.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(bluetooth: BluetoothConnect())
            .modelContainer(for: Item.self, inMemory: true)
    }
}
