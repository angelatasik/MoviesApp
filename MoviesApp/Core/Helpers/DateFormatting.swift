//
//  DateFormatting.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 18.4.26.
//

import Foundation

enum DateFormatting {
    static func yearString(from date: String?) -> String? {
        guard let date, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}
