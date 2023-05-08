import Foundation
import CoreData
@testable import ChatTFS

final class CoreDataStackProtocolMock: CoreDataStackProtocol {

    var invokedFetchChannelsList = false
    var invokedFetchChannelsListCount = 0
    var stubbedFetchChannelsListError: Error?
    var stubbedFetchChannelsListResult: [DBChannel]! = []

    func fetchChannelsList() throws -> [DBChannel] {
        invokedFetchChannelsList = true
        invokedFetchChannelsListCount += 1
        if let error = stubbedFetchChannelsListError {
            throw error
        }
        return stubbedFetchChannelsListResult
    }

    var invokedFetchChannel = false
    var invokedFetchChannelCount = 0
    var invokedFetchChannelParameters: (channelID: String, Void)?
    var invokedFetchChannelParametersList = [(channelID: String, Void)]()
    var stubbedFetchChannelError: Error?
    var stubbedFetchChannelResult: DBChannel!

    func fetchChannel(for channelID: String) throws -> DBChannel {
        invokedFetchChannel = true
        invokedFetchChannelCount += 1
        invokedFetchChannelParameters = (channelID, ())
        invokedFetchChannelParametersList.append((channelID, ()))
        if let error = stubbedFetchChannelError {
            throw error
        }
        return stubbedFetchChannelResult
    }

    var invokedFetchChannelMessages = false
    var invokedFetchChannelMessagesCount = 0
    var invokedFetchChannelMessagesParameters: (channelID: String, Void)?
    var invokedFetchChannelMessagesParametersList = [(channelID: String, Void)]()
    var stubbedFetchChannelMessagesError: Error?
    var stubbedFetchChannelMessagesResult: [DBMessage]! = []

    func fetchChannelMessages(for channelID: String) throws -> [DBMessage] {
        invokedFetchChannelMessages = true
        invokedFetchChannelMessagesCount += 1
        invokedFetchChannelMessagesParameters = (channelID, ())
        invokedFetchChannelMessagesParametersList.append((channelID, ()))
        if let error = stubbedFetchChannelMessagesError {
            throw error
        }
        return stubbedFetchChannelMessagesResult
    }

    var invokedSave = false
    var invokedSaveCount = 0
    var stubbedSaveBlockResult: (NSManagedObjectContext, Void)?

    func save(block: @escaping (NSManagedObjectContext) throws -> Void) {
        invokedSave = true
        invokedSaveCount += 1
        if let result = stubbedSaveBlockResult {
            try? block(result.0)
        }
    }

    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (channel: DBChannel, Void)?
    var invokedUpdateParametersList = [(channel: DBChannel, Void)]()
    var shouldInvokeUpdateBlock = false

    func update(channel: DBChannel, block: @escaping () throws -> Void) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (channel, ())
        invokedUpdateParametersList.append((channel, ()))
        if shouldInvokeUpdateBlock {
            try? block()
        }
    }
}
