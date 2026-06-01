import SwiftUI

struct SynastryTypeSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let onSelectType: (SynastryType) -> Void

    private let synastryTypes: [(type: SynastryType, icon: String)] = SynastryType.allCases.map { ($0, $0.icon) }

    @State private var headerOffset: CGFloat = -20
    @State private var headerOpacity: Double = 0

    private var strings: LocalizedStrings {
        localizationManager.strings
    }

    var body: some View {
        ZStack {
            StarFieldBackground()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(synastryTypes.enumerated()), id: \.element.type) { index, item in
                            CategoryCard(
                                title: strings.synastryTitle(for: item.type),
                                description: strings.synastryDescription(for: item.type),
                                icon: item.icon,
                                delay: Double(index) * 0.1
                            ) {
                                onSelectType(item.type)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                headerOffset = 0
                headerOpacity = 1
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.appSerif(size: 20))
                    .foregroundColor(.mutedText)
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(strings.synastrySelectionTitle)
                    .font(.appSerif(size: 22, weight: .semibold))
                    .foregroundColor(.foregroundText)

                Text(strings.synastrySelectionHint)
                    .font(.appSerif(size: 14, weight: .regular))
                    .foregroundColor(.mutedText)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .offset(y: headerOffset)
        .opacity(headerOpacity)
    }
}

struct SynastryTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SynastryTypeSelectionView { type in
            print("Selected: \(type)")
        }
    }
}
