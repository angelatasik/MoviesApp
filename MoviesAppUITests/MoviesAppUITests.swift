//
//  MoviesAppUITests.swift
//  MoviesAppUITests
//
//  Created by Angela Tasikj on 15.4.26.
//

import XCTest

final class MoviesAppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test 1: Open movie detail from trending list

    @MainActor
    func testOpenMovieDetailFromTrending() throws {
        // Wait for the first trending movie cell to appear
        let firstCell = app.cells["trending_movie_cell_0"]
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 10),
            "Trending list should load and display at least one movie cell"
        )

        // Tap the first movie cell
        firstCell.tap()

        // Verify the detail screen appeared by checking for the movie title and back button
        let detailTitle = app.staticTexts["detail_movie_title"]
        XCTAssertTrue(
            detailTitle.waitForExistence(timeout: 5),
            "Detail screen should show the movie title"
        )

        let backButton = app.buttons["detail_back_button"]
        XCTAssertTrue(backButton.exists, "Detail screen should have a back button")

        // Tap back to return to trending
        backButton.tap()

        // Verify we're back on the trending screen
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 5),
            "Should return to the trending list after tapping back"
        )
    }

    // MARK: - Test 2: Open and use search

    @MainActor
    func testSearchForMovie() throws {
        // Wait for trending to load so the toolbar is ready
        let firstCell = app.cells["trending_movie_cell_0"]
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 10),
            "Trending list should load before navigating to search"
        )

        // Tap the search icon in the navigation bar
        let searchButton = app.buttons["search_button"]
        XCTAssertTrue(searchButton.exists, "Search button should be in the toolbar")
        searchButton.tap()

        // Verify the search screen appeared
        let searchField = app.textFields["search_field"]
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5),
            "Search field should appear on the search screen"
        )

        // Type a search query
        searchField.tap()
        searchField.typeText("batman")

        // Wait for search results to appear
        let resultsList = app.scrollViews["search_results_list"]
        XCTAssertTrue(
            resultsList.waitForExistence(timeout: 10),
            "Search results should appear after typing a query"
        )

        // Verify at least one result row exists
        let firstResult = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier == %@", "search_result_row")
        ).firstMatch
        XCTAssertTrue(
            firstResult.waitForExistence(timeout: 10),
            "At least one search result should appear for 'batman'"
        )
    }

    // MARK: - Test 3: Favorites flow

    @MainActor
    func testFavoritesFlow() throws {
        // Wait for trending to load
        let firstCell = app.cells["trending_movie_cell_0"]
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 10),
            "Trending list should load"
        )

        // Tap a movie to open detail
        firstCell.tap()

        // Wait for detail to load
        let detailTitle = app.staticTexts["detail_movie_title"]
        XCTAssertTrue(
            detailTitle.waitForExistence(timeout: 5),
            "Detail screen should appear"
        )

        // Remember the movie title for later verification
        let movieTitle = detailTitle.label

        // Tap the favorite heart button (toggles favorite state)
        let favoriteButton = app.buttons["favorite_button"]
        XCTAssertTrue(
            favoriteButton.waitForExistence(timeout: 5),
            "Favorite button should be on the detail screen"
        )
        favoriteButton.tap()

        // Navigate back to trending
        let backButton = app.buttons["detail_back_button"]
        backButton.tap()

        // Wait for trending to reappear
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 5),
            "Should return to trending"
        )

        // Tap the heart icon in the navigation bar to open Favorites
        let favoritesButton = app.buttons["favorites_button"]
        XCTAssertTrue(favoritesButton.exists, "Favorites button should be in the toolbar")
        favoritesButton.tap()

        // Check if the movie is in favorites
        let favoriteRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier == %@", "favorite_row")
        ).firstMatch
        let movieIsInFavorites = favoriteRow.waitForExistence(timeout: 5)

        if movieIsInFavorites {
            // We just favorited it — verify the title is shown
            let favoriteTitleText = app.staticTexts[movieTitle]
            XCTAssertTrue(
                favoriteTitleText.exists,
                "The movie '\(movieTitle)' should be visible in favorites"
            )
        } else {
            // We just unfavorited it — go back, re-favorite, then verify
            app.buttons["favorites_back_button"].tap()
            XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

            firstCell.tap()
            XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
            favoriteButton.tap()

            backButton.tap()
            XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

            favoritesButton.tap()

            XCTAssertTrue(
                favoriteRow.waitForExistence(timeout: 10),
                "The favorited movie should appear in the favorites list"
            )

            let favoriteTitleText = app.staticTexts[movieTitle]
            XCTAssertTrue(
                favoriteTitleText.exists,
                "The movie '\(movieTitle)' should be visible in favorites"
            )
        }
    }

    // MARK: - Test 4: No connection banner

    @MainActor
    func testNoConnectionBannerAppearsWhenOffline() throws {
        // Launch app with forced offline mode
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-UITest_ForceOffline"]
        offlineApp.launch()

        // Verify the no connection banner is displayed
        let banner = offlineApp.staticTexts["no_connection_banner"]
            .exists
            ? offlineApp.staticTexts["no_connection_banner"]
            : offlineApp.descendants(matching: .any)["no_connection_banner"]

        XCTAssertTrue(
            banner.waitForExistence(timeout: 5),
            "No connection banner should appear when offline"
        )

        // Verify the banner shows the expected text
        let bannerText = offlineApp.staticTexts["No internet connection"]
        XCTAssertTrue(
            bannerText.exists,
            "Banner should display 'No internet connection' message"
        )
    }
}
