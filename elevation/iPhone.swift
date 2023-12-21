import Foundation
import CoreMotion



struct MotionData {
    var timestamp: Date
    var angle: Double
}

class ViewController: ObservableObject {
    var prevFilteredX: Double = 0
    var prevFilteredY: Double = 0
    var prevFilteredZ: Double = 0
    let alpha: Double = 0.2
    let motionManager = CMMotionManager()
    @Published var currentAngle: Double = 0.0

    // Add an array to store motion data
    @Published var motionData = [MotionData]()

    init() {
        // Check if the accelerometer is available
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1  // Updates every 0.1 seconds
        } else {
            print("Accelerometer is not available.")
        }
    }

    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available.")
            return
        }

        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let accelerometerData = data {
                let filteredX = self.alpha * accelerometerData.acceleration.x + (1 - self.alpha) * self.prevFilteredX
                let filteredY = self.alpha * accelerometerData.acceleration.y + (1 - self.alpha) * self.prevFilteredY
                let filteredZ = self.alpha * accelerometerData.acceleration.z + (1 - self.alpha) * self.prevFilteredZ

                // Update previous filtered values
                self.prevFilteredX = filteredX
                self.prevFilteredY = filteredY
                self.prevFilteredZ = filteredZ

                // Calculate angle
                let angle = self.calculateAngle(x: filteredX, y: filteredY, z: filteredZ)
                // Update current angle
                    DispatchQueue.main.async {
                            self.currentAngle = angle
                                // Print the current angle to the console
                                print("Current Angle: \(self.currentAngle)")
                            }

                // Create and append the new data point
                let motionPoint = MotionData(timestamp: Date(), angle: angle)
                self.motionData.append(motionPoint)
                
                //print("X: \(filteredX), Y: \(filteredY), Z: \(filteredZ)")
            }
        }
    }

    // Update the function to stop accelerometer updates and save data
       func stopUpdates() {
           motionManager.stopAccelerometerUpdates()

           // Save data to a CSV file
           let csvString = convertToCSV(motionData: motionData)
           saveCSVToFile(csvString: csvString)

           print("Accelerometer updates stopped.")
       }
    
    private func convertToCSV(motionData: [MotionData]) -> String {
        var csvString = "Timestamp,Angle\n"
        for dataPoint in motionData {
            let csvRow = "\(dataPoint.timestamp),\(dataPoint.angle)\n"
            csvString.append(contentsOf: csvRow)
        }
        return csvString
    }

       // Add this function to save CSV data to a file
       private func saveCSVToFile(csvString: String) {
           let fileName = "MotionData.csv"
           let fileManager = FileManager.default
           do {
               let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
               let fileURL = documentsURL.appendingPathComponent(fileName)
               try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
               print("Motion data saved to \(fileURL)")
           } catch {
               print("Failed to create file: \(error)")
           }
       }
    
    func calculateAngle(x: Double, y: Double, z: Double) -> Double {
        // Example calculation 
        let angleInRadians = atan2(sqrt(x*x + z*z), y)
        let angleInDegrees = angleInRadians * (180.0 / .pi)
        
        // Adjustment to start the measurement from 0 degrees
        let adjustedAngle = angleInDegrees >= 0 ? angleInDegrees : 360 + angleInDegrees
        
        return adjustedAngle
    }
   }
