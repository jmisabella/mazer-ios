//
//  HelpModalView.swift
//  mazer-ios
//
//  Created by Jeffrey Isabella on 7/14/25.
//

import SwiftUI

struct HelpModalView: View {
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    @Environment(\.colorScheme) private var colorScheme // For dark/light mode support

    var body: some View {
        ZStack {
            // Darken the background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // The modal popup content
            VStack(spacing: 20) {
                // Upper right X close button
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Close help")
                }
                
                // Page content
                VStack(spacing: 12) {
                    switch currentPage {
                    case 0:
                        Text("The goal is to navigate from the blue starting point to the red goal point.")
                            .multilineTextAlignment(.center)
                            .font(.body)
                    case 1:
                        Text("To navigate the maze, use your finger to drag or flick in the direction you want to move—from anywhere on the grid.")
                            .multilineTextAlignment(.center)
                            .font(.body)
                    case 2:
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("Alternatively, click to toggle on the navigation buttons—which are useful when finer-grained control is required.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                        }
                    case 3:
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "flame")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("Toggle the heat map for a visual hint indicating the distance to the goal.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                        }
                    case 4:
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Toggle to show the solution at any time.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                        }
                    default:
                        EmptyView()
                    }
                }
                .foregroundColor(colorScheme == .dark ? Color(white: 0.85) : .primary)
                .padding(.horizontal, 20)
                
                // Next/Done button
                if currentPage < 4 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .fontWeight(.bold)
                    .tint(colorScheme == .dark ? CellColors.lighterSky : CellColors.orangeRed)
                } else {
                    Button("Done") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .fontWeight(.bold)
                    .tint(colorScheme == .dark ? CellColors.lighterSky : CellColors.orangeRed)
                }
            }
            .padding(20)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 320) // Limit width for better popup feel
            .transition(.scale) // Add a nice animation
        }
    }
}
