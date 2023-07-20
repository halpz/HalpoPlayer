//
//  SideMenu.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI

struct MenuContent: View {
	var body: some View {
		List {
			Text("My Profile").onTapGesture {
				print("My Profile")
			}
			Text("Posts").onTapGesture {
				print("Posts")
			}
			Text("Logout").onTapGesture {
				print("Logout")
			}
		}
	}
}

struct SideMenu: View {
	let width: CGFloat
	let isOpen: Bool
	let menuClose: () -> Void
	
	var body: some View {
		ZStack {
			GeometryReader { _ in
				EmptyView()
			}
			.background(Color.gray.opacity(0.3))
			.opacity(self.isOpen ? 1.0 : 0.0)
//			.animation(Animation.easeIn.delay(0.25))
			.animation(.easeIn, value: 0.25)
			.onTapGesture {
				self.menuClose()
			}
			
			HStack {
				MenuContent()
					.frame(width: self.width)
					.background(Color.white)
					.offset(x: self.isOpen ? 0 : -self.width)
//					.animation(.default, value: 1)
				
				Spacer()
			}
		}
	}
}
