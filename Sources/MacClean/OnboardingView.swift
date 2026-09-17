import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @State private var currentStep = 0
    let onFinish: () -> Void

    private let totalSteps = 4

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color.accentColor.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.25))
                            .frame(width: index == currentStep ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .padding(.top, 36)

                Spacer()

                // Slide content
                Group {
                    switch currentStep {
                    case 0: slide0
                    case 1: slide1
                    case 2: slide2
                    case 3: slide3
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStep)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentStep)

                Spacer()

                // Navigation buttons
                HStack(spacing: 14) {
                    if currentStep > 0 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Label(L(.onboardingBack), systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    } else {
                        // Invisible placeholder to keep layout stable
                        Label(L(.onboardingBack), systemImage: "chevron.left")
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .hidden()
                    }

                    Spacer()

                    if currentStep < totalSteps - 1 {
                        Button {
                            withAnimation { currentStep += 1 }
                        } label: {
                            Text(L(.onboardingContinue))
                                .frame(minWidth: 110)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                    } else {
                        Button {
                            onFinish()
                        } label: {
                            Text(L(.onboardingGetStarted))
                                .frame(minWidth: 110)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 40)
            }
        }
        .frame(width: 680, height: 520)
    }

    // MARK: - Slide 0: Welcome

    private var slide0: some View {
        VStack(spacing: 0) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.cyan, .blue, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 96, height: 96)
                    .shadow(color: .accentColor.opacity(0.35), radius: 18, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 28)

            Text(L(.onboardingWelcomeTitle))
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)

            Text(L(.onboardingWelcomeSubtitle))
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 48)
        }
    }

    // MARK: - Slide 1: Scan first

    private var slide1: some View {
        OnboardingSlide(
            icon: "magnifyingglass.circle.fill",
            iconColor: .accentColor,
            title: L(.onboardingSlide2Title),
            bodyText: L(.onboardingSlide2Body),
            bullets: [
                OnboardingBullet(icon: "checkmark.circle", color: .green,
                                 text: slideBullet(for: 0, index: 0)),
                OnboardingBullet(icon: "eye", color: .blue,
                                 text: slideBullet(for: 0, index: 1)),
                OnboardingBullet(icon: "hand.raised.fill", color: .orange,
                                 text: slideBullet(for: 0, index: 2))
            ]
        )
    }

    // MARK: - Slide 2: Categories

    private var slide2: some View {
        OnboardingSlide(
            icon: "square.grid.2x2.fill",
            iconColor: .purple,
            title: L(.onboardingSlide3Title),
            bodyText: L(.onboardingSlide3Body),
            bullets: [
                OnboardingBullet(icon: "shippingbox.fill", color: .blue,
                                 text: slideBullet(for: 1, index: 0)),
                OnboardingBullet(icon: "hammer.fill", color: .orange,
                                 text: slideBullet(for: 1, index: 1)),
                OnboardingBullet(icon: "externaldrive.fill", color: .pink,
                                 text: slideBullet(for: 1, index: 2))
            ]
        )
    }

    // MARK: - Slide 3: Safety

    private var slide3: some View {
        OnboardingSlide(
            icon: "lock.shield.fill",
            iconColor: .green,
            title: L(.onboardingSlide4Title),
            bodyText: L(.onboardingSlide4Body),
            bullets: [
                OnboardingBullet(icon: "server.rack", color: .red,
                                 text: slideBullet(for: 2, index: 0)),
                OnboardingBullet(icon: "checkmark.seal.fill", color: .green,
                                 text: slideBullet(for: 2, index: 1)),
                OnboardingBullet(icon: "trash.slash.fill", color: .secondary,
                                 text: slideBullet(for: 2, index: 2))
            ]
        )
    }

    // MARK: - Bullet text helpers (language-aware)

    private func slideBullet(for slide: Int, index: Int) -> String {
        switch langManager.language {
        case .turkish:
            return turkishBullets[slide][index]
        case .english:
            return englishBullets[slide][index]
        case .russian:
            return russianBullets[slide][index]
        }
    }

    private let turkishBullets: [[String]] = [
        // Slide 1
        [
            "Önce tüm temizlenebilir alan bulunur",
            "Sonuçlar önce sana gösterilir",
            "Hiçbir şey onayın olmadan silinmez"
        ],
        // Slide 2
        [
            "Önbellekler ve günlükler ayrı kategoride",
            "Xcode DerivedData ve simülatör verileri",
            "500 MB üzeri büyük ve eski dosyalar"
        ],
        // Slide 3
        [
            "Hiçbir dosya sunucuya gönderilmez",
            "Her silme işlemi onayını ister",
            "Çöp Kutusu'ndaki öğeler geri alınabilir"
        ]
    ]

    private let englishBullets: [[String]] = [
        [
            "All cleanable space is found first",
            "Results are shown to you before any action",
            "Nothing is deleted without your approval"
        ],
        [
            "Caches and logs in separate categories",
            "Xcode DerivedData and simulator data",
            "Large and old files over 500 MB"
        ],
        [
            "No file is ever sent to a server",
            "Every deletion requires your confirmation",
            "Items in Trash can be recovered"
        ]
    ]

    private let russianBullets: [[String]] = [
        [
            "Сначала находится всё пространство для очистки",
            "Результаты показываются вам до любого действия",
            "Ничего не удаляется без вашего подтверждения"
        ],
        [
            "Кэши и журналы в отдельных категориях",
            "Xcode DerivedData и данные симулятора",
            "Большие старые файлы от 500 МБ"
        ],
        [
            "Ни один файл не отправляется на сервер",
            "Каждое удаление требует подтверждения",
            "Элементы в Корзине можно восстановить"
        ]
    ]
}

// MARK: - Supporting Views

private struct OnboardingBullet: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let text: String
}

private struct OnboardingSlide: View {
    let icon: String
    let iconColor: Color
    let title: String
    let bodyText: String
    let bullets: [OnboardingBullet]

    var body: some View {
        VStack(spacing: 0) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(iconColor)
                .symbolRenderingMode(.hierarchical)
                .shadow(color: iconColor.opacity(0.3), radius: 12, y: 6)
                .padding(.bottom, 24)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text(bodyText)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 52)

            // Bullets
            VStack(alignment: .leading, spacing: 12) {
                ForEach(bullets) { bullet in
                    HStack(spacing: 12) {
                        Image(systemName: bullet.icon)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(bullet.color)
                            .frame(width: 26)
                        Text(bullet.text)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.85))
                    }
                }
            }
            .padding(.top, 28)
            .padding(.horizontal, 56)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
