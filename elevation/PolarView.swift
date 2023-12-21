import SwiftUI

struct Graph: View {
    var dataPoints: [Double]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw Y-axis
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                }
                .stroke(Color.black, lineWidth: 2)

                // Draw data line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))

                    for i in 0..<dataPoints.count {
                        let x = geometry.size.width * CGFloat(i) / CGFloat(dataPoints.count - 1)
                        let y = geometry.size.height * (1 - CGFloat(min(max(dataPoints[i], 0), 90) / 90))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                // Add Y-axis labels
                ForEach(0..<5) { index in
                    let yValue = Double(index) * 18 // Adjust this value based on your needs
                    let yPosition = geometry.size.height * (1 - CGFloat(yValue / 90))

                    Text("\(Int(yValue))°")
                        .font(.caption)
                        .position(x: 10, y: yPosition)
                }
            }
        }
        .padding()
    }
}

struct PolarView: View {
    @ObservedObject var bluetooth: BluetoothConnect
    @State private var isMeasuring = false
    @State private var timer: Timer?
    @State private var showAlert = false
    @State private var angleData: [Double] = []

    var body: some View {
        VStack {
            Graph(dataPoints: angleData)
                .padding()

            Button(action: {
                bluetooth.start()
            }) {
                Text("Start")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isMeasuring || bluetooth.isConnected)

            Button(action: {
                stopMeasurement()
            }) {
                Text("Stop")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .disabled(!isMeasuring || !bluetooth.isConnected)
        }
        .onReceive(bluetooth.$currentAngle) { angle in
            // Update the angle data for the graph
            angleData.append(angle)
        }
        .onReceive(bluetooth.$isConnected) { isConnected in
            if isConnected {
                showAlert = true
                startMeasurement()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Bluetooth Connected"),
                message: Text("Polar sensor connected successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func startMeasurement() {
        isMeasuring = true
        angleData = [] // Clear previous data

        // Set up the timer for 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Optionally, perform any actions here
        }
    }

    private func stopMeasurement() {
        isMeasuring = false
        bluetooth.stopAndSaveData()

        // Invalidate the timer to stop it
        timer?.invalidate()
        timer = nil
    }
}
