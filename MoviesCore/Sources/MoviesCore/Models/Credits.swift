//
//  Credits.swift
//  MoviesApp
//
//  Created by Angela Tasikj on 19.4.26.
//

import Foundation

// MARK: - Credits

public struct Credits: Codable, Sendable {
    public let id: Int
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(id: Int, cast: [CastMember], crew: [CrewMember]) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }
}

// MARK: - CastMember

public struct CastMember: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?
    public let order: Int

    public init(id: Int, name: String, character: String, profilePath: String?, order: Int) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }
}

// MARK: - CrewMember

public struct CrewMember: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let job: String
    public let department: String
    public let profilePath: String?

    public init(id: Int, name: String, job: String, department: String, profilePath: String?) {
        self.id = id
        self.name = name
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}
