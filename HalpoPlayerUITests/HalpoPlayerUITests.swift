//
//  HalpoPlayerUITests.swift
//  HalpoPlayerUITests
//
//  Created by paul on 25/08/2023.
//

import XCTest

final class HalpoPlayerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		let app = XCUIApplication()
		app.launchArguments.append("UITEST")
		setupSnapshot(app)
		app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
		
		let app = XCUIApplication()
		XCUIDevice.shared.orientation = .portrait
		app.buttons["Log in"].tap()
		let collectionViewsQuery = app.collectionViews
		collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Save"]/*[[".cells.buttons[\"Save\"]",".buttons[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		sleep(1)
		snapshot("library")
		collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Leave Your Life, Alex Kassian"]/*[[".cells.buttons[\"Leave Your Life, Alex Kassian\"]",".buttons[\"Leave Your Life, Alex Kassian\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		sleep(1)
		snapshot("album")
		collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["1, Leave Your Life (Lonely Hearts Mix), Alex Kassian"]/*[[".cells.buttons[\"1, Leave Your Life (Lonely Hearts Mix), Alex Kassian\"]",".buttons[\"1, Leave Your Life (Lonely Hearts Mix), Alex Kassian\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		sleep(1)
		app.buttons["Leave Your Life (Lonely Hearts Mix)"].tap()
		sleep(1)
		snapshot("nowPlaying")
		app.buttons["books.vertical"].tap()
		sleep(1)
		app.buttons["arrow.down.square"].tap()
		sleep(1)
		snapshot("downloads")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
