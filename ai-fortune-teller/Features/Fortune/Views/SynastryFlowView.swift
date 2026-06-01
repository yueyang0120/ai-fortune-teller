import SwiftUI

/// Wrapper view that manages the entire synastry flow within a single sheet:
/// Step 1: Type selection → Step 2: Two-person input → Submit
/// This ensures proper back navigation and correct state passing between steps.
struct SynastryFlowView: View {
    let onSubmit: (SynastryType, BirthInfo, BirthInfo, RelationshipRole?) -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedType: SynastryType?

    var body: some View {
        if let type = selectedType {
            SynastryInputView(synastryType: type) { personA, personB, role in
                onSubmit(type, personA, personB, role)
            }
            .transition(.move(edge: .trailing))
            // Override the back button inside SynastryInputView to go back to type selection
            // We intercept the back action by wrapping with an environment value
            .environment(\.synastryFlowBack, {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedType = nil
                }
            })
        } else {
            SynastryTypeSelectionView { type in
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedType = type
                }
            }
            .transition(.move(edge: .leading))
        }
    }
}

// MARK: - Environment key for back navigation within synastry flow

private struct SynastryFlowBackKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var synastryFlowBack: (() -> Void)? {
        get { self[SynastryFlowBackKey.self] }
        set { self[SynastryFlowBackKey.self] = newValue }
    }
}
