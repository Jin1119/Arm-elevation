import SwiftUI
struct iPhoneView: View {
    @StateObject var viewModel: ViewController
    @State private var isMeasuring = false
    @State private var timer: Timer?
    @State private var angleData: [Double] = []

    var body: some View {
        VStack {
            Graph(dataPoints: angleData)
                .padding()

            Button(action: {
                startMeasurement()
            }) {
                Text("Start")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isMeasuring)

            Button(action: {
                stopMeasurement()
            }) {
                Text("Stop")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .disabled(!isMeasuring)
        }
        .onReceive(viewModel.$currentAngle) { angle in
            // Update the angle data for the graph
            angleData.append(angle)
        }
    }

    private func startMeasurement() {
        isMeasuring = true
        angleData = [] // Clear previous data
        viewModel.startUpdates()

        // Set up the timer for 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            stopMeasurement()
        }
    }

    private func stopMeasurement() {
        isMeasuring = false
        viewModel.stopUpdates()

        // Invalidate the timer to stop it
        timer?.invalidate()
        timer = nil
    }
}
