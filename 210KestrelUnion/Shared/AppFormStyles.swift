import SwiftUI

struct AppFormSection<Content: View>: View {
    let title: String
    let icon: String?
    let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                content
            }
        }
    }
}

struct AppTextInputArea: View {
    @Binding var text: String
    let placeholder: String
    var shakeTrigger: CGFloat = 0
    var minHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(minHeight: minHeight)
        }
        .padding(12)
        .background(Color("AppBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("AppAccent").opacity(0.2), lineWidth: 1)
        )
        .modifier(ShakeEffect(animatableData: shakeTrigger))
    }
}

struct AppTextFieldInput: View {
    @Binding var text: String
    let placeholder: String
    var shakeTrigger: CGFloat = 0

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(12)
            .background(Color("AppBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("AppAccent").opacity(0.2), lineWidth: 1)
            )
            .modifier(ShakeEffect(animatableData: shakeTrigger))
    }
}

struct MoodTagPicker: View {
    @Binding var selected: Set<MoodTag>
    let maxSelection: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MoodTag.allCases) { tag in
                    Button {
                        FeedbackService.tap()
                        toggle(tag)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tag.symbol)
                            Text(tag.rawValue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selected.contains(tag) ? Color("AppPrimary") : Color("AppBackground"))
                        .foregroundStyle(selected.contains(tag) ? Color("AppBackground") : Color("AppTextSecondary"))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color("AppAccent").opacity(selected.contains(tag) ? 0 : 0.25), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.vertical, 2)
        }
        Text("Choose up to \(maxSelection) tags")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
    }

    private func toggle(_ tag: MoodTag) {
        if selected.contains(tag) {
            selected.remove(tag)
            return
        }
        if selected.count < maxSelection {
            selected.insert(tag)
        }
    }
}

struct ReflectionEntryFormView: View {
    @Binding var text: String
    @Binding var date: Date
    @Binding var selectedMoods: Set<MoodTag>
    var showValidationError: Bool
    var shakeTrigger: CGFloat
    var promptText: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                AppCard {
                    HStack(spacing: 12) {
                        AppIllustrationView(art: .emptyReflections, cornerRadius: 12)
                            .frame(width: 64, height: 64)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New Reflection")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Write freely — even one sentence counts.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                    }
                }

                if let promptText {
                    AppFormSection(title: "Today's Prompt", icon: "lightbulb.fill") {
                        Text(promptText)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                AppFormSection(title: "Reflection", icon: "square.and.pencil") {
                    AppTextInputArea(
                        text: $text,
                        placeholder: "Write your reflection…",
                        shakeTrigger: shakeTrigger
                    )
                    if showValidationError {
                        Text("Please add at least one sentence.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                AppFormSection(title: "Mood Tags", icon: "face.smiling") {
                    MoodTagPicker(selected: $selectedMoods, maxSelection: 2)
                }

                AppFormSection(title: "Date", icon: "calendar") {
                    DatePicker("Reflection Date", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(Color("AppPrimary"))
                        .padding(8)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .colorScheme(.dark)
                }
            }
            .padding(16)
        }
    }
}

struct AddAffirmationFormView: View {
    @Binding var text: String
    var showError: Bool
    var shakeTrigger: CGFloat
    let onAdd: () -> Void

    var body: some View {
        AppFormSection(title: "Create Personal Affirmation", icon: "quote.bubble.fill") {
            AppTextFieldInput(
                text: $text,
                placeholder: "Write an affirmation…",
                shakeTrigger: shakeTrigger
            )
            if showError {
                Text("Please enter a valid affirmation.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Button {
                onAdd()
            } label: {
                Text("Add Affirmation")
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }
}

extension View {
    func appSheetNavigationStyle() -> some View {
        self
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
