//
//  LoginUITests.swift
//  StockFlow
//
//  Created by Cicek on 15.10.26.
//

import XCTest

final class LoginUITests: XCTestCase {

    private var app: XCUIApplication!
    
    // MARK: - Elements
    
    private var emailField: XCUIElement { app.textFields["loginEmailField"] }
    private var passwordField: XCUIElement { app.secureTextFields["loginPasswordField"] }
    private var signInButton: XCUIElement { app.buttons["Sign In"] }

    // MARK: - Setup

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uitesting"]
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Welcome back"].waitForExistence(timeout: 10),
            "Login screen should be shown on a clean launch"
        )
    }

    // MARK: - Tests

    
    @MainActor
    func testLoginScreenShowsFormElements() {
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(signInButton.exists)
        XCTAssertTrue(app.buttons["Create Store"].exists)
    }

    @MainActor
    func testEmptyFormShowsValidationErrors() {
        signInButton.tap()

        XCTAssertTrue(app.staticTexts["Email is required."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Password is required."].exists)
    }
    
    @MainActor
        func testInvalidEmailShowsError() {
            emailField.tap()
            emailField.typeText("not-an-email")
            passwordField.tap()
            passwordField.typeText("123456\n")

            XCTAssertTrue(app.staticTexts["Enter a valid email."].waitForExistence(timeout: 5))
        }
    
    @MainActor
       func testShortPasswordShowsError() {
           emailField.tap()
           emailField.typeText("owner@stockflow.com")
           passwordField.tap()
           passwordField.typeText("123\n")

           XCTAssertTrue(
               app.staticTexts["Password must contain at least 6 characters."]
                   .waitForExistence(timeout: 5)
           )
       }
    
//    @MainActor
//        func testCreateStoreButtonOpensCreateStoreScreen() {
//            app.buttons["Create Store"].tap()
//
//            XCTAssertTrue(app.staticTexts["Full Name"].waitForExistence(timeout: 5))
//        }
}
