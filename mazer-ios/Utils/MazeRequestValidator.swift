import Foundation

struct MazeRequestValidator {
    static func validate(mazeType: MazeType, width: Int, height: Int, algorithm: MazeAlgorithm, captureSteps: Bool) -> Result<String, MazeRequestError> {
        
        // Ensure width and height are valid
        guard width > 0, height > 0 else {
            return .failure(.invalidDimensions)
        }
        
        // Check size constraints when captureSteps is enabled
        if captureSteps && (width > 100 || height > 100) {
            return .failure(.invalidDimensionsForCaptureSteps)
        }
        
        // Construct the MazeRequest object
        let mazeRequest = MazeRequest(
            maze_type: mazeType,
            width: width,
            height: height,
            algorithm: algorithm,
            capture_steps: captureSteps
        )
        
        // Encode as JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(mazeRequest)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return .success(jsonString)
            } else {
                return .failure(.invalidMazeRequestJSON)
            }
        } catch {
            return .failure(.invalidMazeRequestJSON)
        }
    }
}

//struct MazeRequestValidator {
//    static func validate(mazeType: MazeType, width: Int, height: Int, algorithm: MazeAlgorithm) -> Result<String, MazeRequestError> {
//        
//        // Ensure width and height are valid
//        guard width > 0, height > 0 else {
//            return .failure(.invalidDimensions)
//        }
//
//
//        // Construct the MazeRequest object
//        let mazeRequest = MazeRequest(
//            maze_type: mazeType,
//            width: width,
//            height: height,
//            algorithm: algorithm
//        )
//
//        // Encode as JSON
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        do {
//            let jsonData = try encoder.encode(mazeRequest)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                return .success(jsonString)
//            } else {
//                return .failure(.invalidMazeRequestJSON)
//            }
//        } catch {
//            return .failure(.invalidMazeRequestJSON)
//        }
//    }
//}
//
