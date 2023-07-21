//
//  ExpandableText.swift
//  HalpoPlayer
//
//  Created by paul on 21/07/2023.
//

import SwiftUI

struct ExpandableText: View {

	@State private var expanded: Bool = false
	@State private var truncated: Bool = false
	private var text: String
	private var localizedStringKey: LocalizedStringKey?

	init(_ text: String) {
		self.text = text
	}
	init(_ localizedStringKey: LocalizedStringKey) {
		self.text = Mirror(reflecting: localizedStringKey).children.first(where: { $0.label == "key" })?.value as? String ?? ""
		self.localizedStringKey = localizedStringKey
	}

	private func determineTruncation(_ geometry: GeometryProxy) {
		let total = self.text.boundingRect(
			with: CGSize(
				width: geometry.size.width,
				height: .greatestFiniteMagnitude
			),
			options: .usesLineFragmentOrigin,
			attributes: [.font: UIFont.systemFont(ofSize: 16)],
			context: nil
		)

		if total.size.height > geometry.size.height {
			self.truncated = true
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			if let localizedStringKey = localizedStringKey {
				Text(localizedStringKey)
					.font(.system(size: 16))
					.lineLimit(self.expanded ? nil : 3)
					.background(GeometryReader { geometry in
						Color.clear.onAppear {
							self.determineTruncation(geometry)
						}
					})
			} else {
				Text(self.text)
					.font(.system(size: 16))
					.lineLimit(self.expanded ? nil : 3)
					.background(GeometryReader { geometry in
						Color.clear.onAppear {
							self.determineTruncation(geometry)
						}
					})
			}
			

			if self.truncated {
				self.toggleButton
			}
		}
	}

	var toggleButton: some View {
		Button {
			self.expanded.toggle()
		} label: {
			Text(self.expanded ? "Show less" : "Show more")
				.font(.caption)
				.foregroundColor(.accentColor)
		}
	}

}
