import SwiftUI

struct EnvironmentalConditionsGrid: View {
    let conditions: [EnvironmentalCondition]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Conditions")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(conditions) { condition in
                    ConditionCard(condition: condition)
                }
            }
        }
    }
}

struct ConditionCard: View {
    let condition: EnvironmentalCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: condition.icon)
                    .foregroundColor(.jubileePrimary)
                    .font(.title2)
                Spacer()
                if condition.isOptimal {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(condition.label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(condition.value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(condition.trend)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.jubileeSecondary)
        )
    }
}

struct RecentActivitySection: View {
    let activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: iconForActivityType(activity.type))
                .foregroundColor(.jubileePrimary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.jubileeSecondary)
        )
    }
    
    private func iconForActivityType(_ type: ActivityType) -> String {
        switch type {
        case .sighting:
            return "eye.fill"
        case .prediction:
            return "chart.line.uptrend.xyaxis"
        case .community:
            return "person.2.fill"
        }
    }
}

#Preview {
    VStack {
        EnvironmentalConditionsGrid(conditions: [
            EnvironmentalCondition(
                icon: "thermometer",
                label: "Water Temp",
                value: "78°F",
                trend: "↑ 2° from yesterday",
                isOptimal: true
            ),
            EnvironmentalCondition(
                icon: "drop.fill",
                label: "Dissolved O₂",
                value: "3.2 ppm",
                trend: "↓ 0.1 from yesterday",
                isOptimal: false
            )
        ])
        
        RecentActivitySection(activities: [
            Activity(id: UUID(), title: "New sighting reported", subtitle: "Fairhope Pier - 2 min ago", type: .sighting)
        ])
    }
    .preferredColorScheme(.dark)
    .background(Color.jubileeBackground)
}