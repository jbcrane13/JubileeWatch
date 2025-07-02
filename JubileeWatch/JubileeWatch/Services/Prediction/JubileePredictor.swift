import Foundation

class JubileePredictor {
    
    func calculateProbability(from environmentalData: EnvironmentalReading) -> JubileePrediction {
        let factors = analyzeEnvironmentalFactors(environmentalData)
        let probability = calculateOverallProbability(factors: factors)
        let confidence = determineConfidence(probability: probability, factors: factors)
        
        return JubileePrediction(
            id: UUID(),
            timestamp: Date(),
            location: environmentalData.location,
            probability: probability,
            confidence: confidence,
            contributingFactors: factors,
            predictedTimeWindow: DateInterval(start: Date(), duration: 7200), // 2 hours
            lastUpdated: Date()
        )
    }
    
    private func analyzeEnvironmentalFactors(_ data: EnvironmentalReading) -> [ContributingFactor] {
        var factors: [ContributingFactor] = []
        
        // Water Temperature Analysis
        let tempImpact = analyzeWaterTemperature(data.waterTemperature)
        factors.append(ContributingFactor(
            factor: .waterTemperature,
            value: data.waterTemperature,
            impact: tempImpact,
            threshold: Threshold(min: 75.0, max: 85.0, optimal: 78.0)
        ))
        
        // Dissolved Oxygen Analysis
        if let dissolvedOxygen = data.dissolvedOxygen {
            let oxygenImpact = analyzeDissolvedOxygen(dissolvedOxygen)
            factors.append(ContributingFactor(
                factor: .dissolvedOxygen,
                value: dissolvedOxygen,
                impact: oxygenImpact,
                threshold: Threshold(min: 0.0, max: 4.0, optimal: 2.0)
            ))
        }
        
        // Wind Speed Analysis
        let windImpact = analyzeWindSpeed(data.windSpeed)
        factors.append(ContributingFactor(
            factor: .windSpeed,
            value: data.windSpeed,
            impact: windImpact,
            threshold: Threshold(min: 0.0, max: 8.0, optimal: 3.0)
        ))
        
        // Humidity Analysis
        let humidityImpact = analyzeHumidity(data.humidity)
        factors.append(ContributingFactor(
            factor: .humidity,
            value: data.humidity,
            impact: humidityImpact,
            threshold: Threshold(min: 80.0, max: 100.0, optimal: 90.0)
        ))
        
        return factors
    }
    
    private func analyzeWaterTemperature(_ temperature: Double) -> Double {
        // Optimal temperature range for jubilees is 76-80°F
        switch temperature {
        case 76...80:
            return 0.8
        case 72...76, 80...84:
            return 0.5
        case 68...72, 84...88:
            return 0.2
        default:
            return -0.3
        }
    }
    
    private func analyzeDissolvedOxygen(_ oxygen: Double) -> Double {
        // Low dissolved oxygen (hypoxia) drives jubilees
        switch oxygen {
        case 0.0...2.0:
            return 0.9
        case 2.0...3.0:
            return 0.6
        case 3.0...4.0:
            return 0.3
        default:
            return -0.5
        }
    }
    
    private func analyzeWindSpeed(_ windSpeed: Double) -> Double {
        // Light winds are favorable
        switch windSpeed {
        case 0...3:
            return 0.7
        case 3...6:
            return 0.4
        case 6...10:
            return 0.1
        default:
            return -0.4
        }
    }
    
    private func analyzeHumidity(_ humidity: Double) -> Double {
        // High humidity is associated with jubilees
        switch humidity {
        case 85...100:
            return 0.6
        case 70...85:
            return 0.3
        case 50...70:
            return 0.0
        default:
            return -0.2
        }
    }
    
    private func calculateOverallProbability(factors: [ContributingFactor]) -> Double {
        let baselineProbability = 30.0
        let totalImpact = factors.reduce(0.0) { $0 + $1.impact }
        let weightedImpact = totalImpact * 20.0 // Scale factor
        
        let probability = baselineProbability + weightedImpact
        return max(0.0, min(100.0, probability))
    }
    
    private func determineConfidence(probability: Double, factors: [ContributingFactor]) -> ConfidenceLevel {
        let factorConsistency = factors.allSatisfy { abs($0.impact) > 0.3 }
        
        switch probability {
        case 0..<30:
            return factorConsistency ? .moderate : .low
        case 30..<60:
            return factorConsistency ? .high : .moderate
        case 60..<80:
            return factorConsistency ? .high : .moderate
        default:
            return factorConsistency ? .critical : .high
        }
    }
}