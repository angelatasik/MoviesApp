//
//  Credits.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 16.4.26.
//

import Foundation

// MARK: - Credits

struct Credits: Decodable, Sendable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

// MARK: - CastMember

struct CastMember: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

// MARK: - CrewMember

struct CrewMember: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
}
