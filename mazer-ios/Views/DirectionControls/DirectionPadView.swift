////
////  DirectionPadView.swift
////  mazer-ios
////
////  Created by Jeffrey Isabella on 4/20/25.
////
//
//import SwiftUI
//
//struct DirectionPadView<Dir: Hashable>: View {
//    let layout: [[Dir]]
//    let iconName: (Dir) -> String
//    let action: (Dir) -> Void
//
//    var body: some View {
//        VStack(spacing: 4) {
//            ForEach(layout, id: \.self) { row in
//                HStack(spacing: 4) {
//                    ForEach(row, id: \.self) { dir in
//                        Button {
//                            action(dir)
//                        } label: {
//                            Image(systemName: iconName(dir))
//                                .symbolRenderingMode(.hierarchical)
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundColor(.primary)
//                        }
//                        .buttonStyle(DPadButtonStyle())
//                    }
//                }
//            }
//        }
//        .padding(8)
//        .background(
//            Rectangle()
//                .fill(Color.gray.opacity(0.6))
//                .cornerRadius(12)
//        )
//        .shadow(radius: 4)
//    }
//}
