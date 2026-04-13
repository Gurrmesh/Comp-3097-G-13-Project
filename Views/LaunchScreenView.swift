// LaunchScreenView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct LaunchScreenView: View {
    @Binding var showLaunch: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.10, blue: 0.18),
                    Color(red: 0.06, green: 0.20, blue: 0.38),
                    Color(red: 0.09, green: 0.13, blue: 0.24),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 24)

                Text("Task Sphere")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Smart Task & Productivity Manager")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                Spacer()

                // Get Started button
                Button {
                    showLaunch = false
                } label: {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.20, blue: 0.38))
                        .frame(width: 240, height: 54)
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.bottom, 40)

                // Course info
                VStack(spacing: 5) {
                    Text("COMP3097 · Group 13 · Winter 2026")
                    Text("Gurrmesh Singgh · 101471817")
                }
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.35))
                .padding(.bottom, 44)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView(showLaunch: .constant(true))
    }
}
