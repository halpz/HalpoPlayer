//
//  HTMLConverter.swift
//  HalpoPlayer
//
//  Created by paul on 20/07/2023.
//

import SwiftUI

enum HTMLToMarkdownConverter {

	// MARK: - Public methods
	/// Converts the HTML-tags in the given string to their corresponding markdown tags.
	///
	/// - SeeAlso: See type `HTMLToMarkdownConverter.Tags` for a list of supported HTML-tags.
	static func convert(_ htmlAsString: String) -> String {
		// Convert "basic" HTML-tags that don't use an attribute.
		let markdownAsString = Tags.allCases.reduce(htmlAsString) { result, textFormattingTag in
			result
				.replacingOccurrences(of: textFormattingTag.openingHtmlTag, with: textFormattingTag.markdownTag)
				.replacingOccurrences(of: textFormattingTag.closingHtmlTag, with: textFormattingTag.markdownTag)
		}

		// Hyperlinks use an attribute and therefore need to be handled differently.
		return convertHtmlLinksToMarkdown(markdownAsString)
	}

	// MARK: - Private methods
	/// Converts hyperlinks in HTML-format to their corresponding markdown representations.
	///
	/// - Note: Currently we only support a basic HTML syntax without any attributed other than `href`.
	///         E.g. `<a href="URL">TEXT</a>` will be converted to `[TEXT](URL)`
	///
	/// - Parameter htmlAsString: The string containing hyperlinks in HTML-format.
	///
	/// - Returns: A string with hyperlinks converted to their corresponding markdown representations.
	private static func convertHtmlLinksToMarkdown(_ htmlAsString: String) -> String {
		htmlAsString.replacingOccurrences(of: "<a href=\"(.+)\">(.+)</a>",
										  with: "[$2]($1)",
										  options: .regularExpression,
										  range: nil)
	}
}

extension HTMLToMarkdownConverter {

	/// The supported tags inside a string we can format.
	enum Tags: String, CaseIterable {
		case strong
		case em
		case s
		case code

		// Hyperlinks need to be handled differently, as they not only have simple opening and closing tag, but also use the attribute `href`.
		// See private method `Text.convertHtmlLinksToMarkdown(:)` for further details.
		// case a
		// MARK: - Public properties
		var openingHtmlTag: String {
			"<\(rawValue)>"
		}

		var closingHtmlTag: String {
			"</\(rawValue)>"
		}

		var markdownTag: String {
			switch self {
			case .strong:
				return "**"

			case .em:
				return "*"

			case .s:
				return "~~"

			case .code:
				return "`"
			}
		}
	}
}

@available(iOS 15.0, *)
extension Text {

	// MARK: - Initializer
	/// Renders the given string containing HTML-tags with the related formatting.
	///
	/// - SeeAlso: See type `HTMLToMarkdownConverter.Tags` for a list of supported HTML-tags.
	init(html htmlAsString: String) {
		let markdownAsString = HTMLToMarkdownConverter.convert(htmlAsString)

		do {
			let markdownAsAttributedString = try AttributedString(markdown: markdownAsString)
			self = .init(markdownAsAttributedString)
		} catch {
			print("⚠️ – Couldn't parse markdown: \(error)")

			// Show the "plain" markdown string as a fallback.
			self = .init(markdownAsString)
		}
	}
}
