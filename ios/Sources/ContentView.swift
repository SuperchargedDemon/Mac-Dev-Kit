import SwiftUI

struct Feature: Identifiable {
    let id = UUID()
    let no: String
    let title: String
    let detail: String
}

struct ContentView: View {
    @State private var count = 0

    private let features = [
        Feature(no: "01", title: "界面设计", detail: "从信息结构到像素细节，做能被看懂、能被用顺的界面。"),
        Feature(no: "02", title: "前端开发", detail: "语义化结构、可维护的样式、不炫技的交互。"),
        Feature(no: "03", title: "体验打磨", detail: "动效克制、响应式完整、键盘可达。")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.07),
                    Color(red: 0.09, green: 0.07, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.49, green: 0.36, blue: 1.0).opacity(0.32))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(x: -160, y: -220)

            Circle()
                .fill(Color(red: 0.25, green: 0.78, blue: 1.0).opacity(0.22))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: 220, y: 260)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        Text("Aurora")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Spacer()
                        Text("SwiftUI · 原生")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("DESIGN & CODE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(4)
                            .foregroundStyle(Color(red: 0.25, green: 0.78, blue: 1.0))

                        Text("把想法")
                            .font(.system(size: 46, weight: .heavy, design: .rounded))
                        HStack(spacing: 0) {
                            Text("点亮")
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.55, green: 0.43, blue: 1.0),
                                            Color(red: 0.25, green: 0.78, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("成界面")
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                        }

                        Text("同一个 ContentView，在 iPhone 和 Mac 上都能编译运行。\n点下面的按钮，看看状态能不能跟着走。")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                                count += 1
                            }
                        } label: {
                            Text(count == 0 ? "点亮一次" : "已点亮 \(count) 次")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 11)
                                .background(
                                    Capsule().fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.55, green: 0.43, blue: 1.0),
                                                Color(red: 0.25, green: 0.78, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)

                        if count > 0 {
                            Button("重置") {
                                withAnimation(.easeOut(duration: 0.2)) { count = 0 }
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 14))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 11)
                            .background(
                                Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .foregroundStyle(.secondary)
                        }
                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 170), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(features) { feature in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(feature.no)
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(2)
                                    .foregroundStyle(Color(red: 0.25, green: 0.78, blue: 1.0))
                                Text(feature.title)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(feature.detail)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
                            )
                        }
                    }

                    Divider().overlay(Color.white.opacity(0.08))

                    HStack {
                        Text("© 2026 Aurora Studio")
                        Spacer()
                        Text(platformLabel)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                }
                .padding(36)
                .frame(maxWidth: 780, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
    }

    private var platformLabel: String {
        #if os(macOS)
        return "运行在 macOS"
        #else
        return "运行在 iOS"
        #endif
    }
}

#Preview {
    ContentView()
}
