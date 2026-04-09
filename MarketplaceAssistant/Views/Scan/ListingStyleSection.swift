import SwiftUI

struct ListingStyleSection: View {
    @Binding var sellingStyle: SellingStyle
    @Binding var pricingStrategy: PricingStrategy
    @Binding var conditionDetail: ConditionDetail
    @Binding var selectedLogistics: Set<LogisticsOption>
    @Binding var isExpanded: Bool
    let styleDescription: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("☰ Listing Style")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(styleDescription)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    styleGroup("SELLING STYLE") {
                        FlowLayout(spacing: 8) {
                            ForEach(SellingStyle.allCases) { style in
                                PillButton(
                                    title: "\(style.icon) \(style.rawValue)",
                                    isSelected: sellingStyle == style
                                ) {
                                    sellingStyle = style
                                }
                            }
                        }
                    }

                    styleGroup("PRICING") {
                        FlowLayout(spacing: 8) {
                            ForEach(PricingStrategy.allCases) { strategy in
                                PillButton(
                                    title: "\(strategy.icon) \(strategy.rawValue)",
                                    isSelected: pricingStrategy == strategy
                                ) {
                                    pricingStrategy = strategy
                                }
                            }
                        }
                    }

                    styleGroup("CONDITION DETAIL") {
                        FlowLayout(spacing: 8) {
                            ForEach(ConditionDetail.allCases) { detail in
                                PillButton(
                                    title: "\(detail.icon) \(detail.rawValue)",
                                    isSelected: conditionDetail == detail
                                ) {
                                    conditionDetail = detail
                                }
                            }
                        }
                    }

                    styleGroup("LOGISTICS") {
                        FlowLayout(spacing: 8) {
                            ForEach(LogisticsOption.allCases) { option in
                                PillButton(
                                    title: "\(option.icon) \(option.rawValue)",
                                    isSelected: selectedLogistics.contains(option)
                                ) {
                                    if selectedLogistics.contains(option) {
                                        selectedLogistics.remove(option)
                                    } else {
                                        selectedLogistics.insert(option)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.top, 4)
            }
        }
    }

    private func styleGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            content()
        }
    }
}

// Wrapping flow layout for pill buttons (iOS 16+ Layout protocol)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
