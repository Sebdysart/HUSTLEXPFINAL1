//
//  SquadService.swift
//  hustleXP final1
//
//  v2.4.0: Squads Mode API Service
//  Handles squad CRUD, invites, and squad task management
//

import Foundation
import Combine

@MainActor
final class SquadService: ObservableObject {
    static let shared = SquadService()

    private let trpc: TRPCClientProtocol

    @Published var isLoading = false
    @Published var error: Error?

    init(client: TRPCClientProtocol = TRPCClient.shared) {
        self.trpc = client
    }

    // MARK: - Squad CRUD

    func createSquad(name: String, emoji: String, tagline: String?) async throws -> HXSquad {
        isLoading = true
        defer { isLoading = false }

        struct CreateSquadInput: Codable {
            let name: String
            let emoji: String
            let tagline: String?
        }

        let squad: HXSquad = try await trpc.call(
            router: "squad",
            procedure: "create",
            input: CreateSquadInput(name: name, emoji: emoji, tagline: tagline)
        )

        HXLogger.info("SquadService: Created squad '\(name)'", category: "General")
        return squad
    }

    func getMySquads() async throws -> [HXSquad] {
        struct EmptyInput: Codable {}

        let squads: [HXSquad] = try await trpc.call(
            router: "squad",
            procedure: "listMine",
            type: .query,
            input: EmptyInput()
        )

        HXLogger.info("SquadService: Fetched \(squads.count) squads", category: "General")
        return squads
    }

    func getSquad(id: String) async throws -> HXSquad {
        struct GetSquadInput: Codable {
            let id: String
        }

        let squad: HXSquad = try await trpc.call(
            router: "squad",
            procedure: "getById",
            type: .query,
            input: GetSquadInput(id: id)
        )

        return squad
    }

    func disbandSquad(id: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct DisbandInput: Codable {
            let id: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "squad",
            procedure: "disband",
            input: DisbandInput(id: id)
        )

        HXLogger.info("SquadService: Disbanded squad \(id)", category: "General")
    }

    func leaveSquad(squadId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct LeaveInput: Codable {
            let squadId: String
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "squad",
            procedure: "leave",
            input: LeaveInput(squadId: squadId)
        )

        HXLogger.info("SquadService: Left squad \(squadId)", category: "Squad")
    }

    // MARK: - Squad Invites

    func inviteMember(squadId: String, userId: String) async throws -> SquadInvite {
        isLoading = true
        defer { isLoading = false }

        struct InviteInput: Codable {
            let squadId: String
            let inviteeId: String
        }

        let invite: SquadInvite = try await trpc.call(
            router: "squad",
            procedure: "invite",
            input: InviteInput(squadId: squadId, inviteeId: userId)
        )

        HXLogger.info("SquadService: Invited \(userId) to squad", category: "General")
        return invite
    }

    func respondToInvite(inviteId: String, accept: Bool) async throws {
        isLoading = true
        defer { isLoading = false }

        struct RespondInput: Codable {
            let inviteId: String
            let accept: Bool
        }

        struct EmptyResponse: Codable {}

        let _: EmptyResponse = try await trpc.call(
            router: "squad",
            procedure: "respondToInvite",
            input: RespondInput(inviteId: inviteId, accept: accept)
        )

        HXLogger.info("SquadService: \(accept ? "Accepted" : "Declined") invite", category: "General")
    }

    func getPendingInvites() async throws -> [SquadInvite] {
        struct EmptyInput: Codable {}

        let invites: [SquadInvite] = try await trpc.call(
            router: "squad",
            procedure: "listInvites",
            type: .query,
            input: EmptyInput()
        )

        return invites
    }

    // MARK: - Squad Tasks

    func getSquadTasks(squadId: String) async throws -> [SquadTask] {
        struct GetTasksInput: Codable {
            let squadId: String
        }

        let tasks: [SquadTask] = try await trpc.call(
            router: "squad",
            procedure: "listTasks",
            type: .query,
            input: GetTasksInput(squadId: squadId)
        )

        return tasks
    }

    func acceptSquadTask(squadTaskId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        struct AcceptTaskInput: Codable {
            let squadTaskId: String
        }

        struct AcceptResponse: Codable {
            let id: String
            let squadTaskId: String
            let workerId: String
            let acceptedAt: Date
            let taskStatus: String
        }

        let _: AcceptResponse = try await trpc.call(
            router: "squad",
            procedure: "acceptTask",
            input: AcceptTaskInput(squadTaskId: squadTaskId)
        )

        HXLogger.info("SquadService: Accepted squad task", category: "Squad")
    }

    // MARK: - Leaderboard

    func getLeaderboard() async throws -> [HXSquad] {
        struct EmptyInput: Codable {}

        let squads: [HXSquad] = try await trpc.call(
            router: "squad",
            procedure: "leaderboard",
            type: .query,
            input: EmptyInput()
        )

        return squads
    }
}
