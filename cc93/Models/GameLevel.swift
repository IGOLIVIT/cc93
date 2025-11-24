//
//  GameLevel.swift
//  Luminal Quest
//
//  Created by Luminal Quest Team
//

import Foundation

struct GameLevel: Identifiable, Codable {
    let id: UUID
    let levelNumber: Int
    let title: String
    let description: String
    let difficulty: Difficulty
    let targetScore: Int
    let timeLimit: TimeInterval?
    let puzzlePattern: [PuzzleNode]
    let isUnlocked: Bool
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
        
        var multiplier: Double {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            case .expert: return 3.0
            }
        }
    }
    
    init(id: UUID = UUID(), levelNumber: Int, title: String, description: String, difficulty: Difficulty, targetScore: Int, timeLimit: TimeInterval? = nil, puzzlePattern: [PuzzleNode] = [], isUnlocked: Bool = false) {
        self.id = id
        self.levelNumber = levelNumber
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.targetScore = targetScore
        self.timeLimit = timeLimit
        self.puzzlePattern = puzzlePattern
        self.isUnlocked = isUnlocked
    }
}

struct PuzzleNode: Identifiable, Codable {
    let id: UUID
    let position: CGPoint
    let nodeType: NodeType
    let connections: [UUID]
    let value: Int
    
    enum NodeType: String, Codable {
        case start
        case checkpoint
        case obstacle
        case goal
        case powerup
    }
    
    init(id: UUID = UUID(), position: CGPoint, nodeType: NodeType, connections: [UUID] = [], value: Int = 0) {
        self.id = id
        self.position = position
        self.nodeType = nodeType
        self.connections = connections
        self.value = value
    }
}

extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
    
    enum CodingKeys: String, CodingKey {
        case x, y
    }
}

