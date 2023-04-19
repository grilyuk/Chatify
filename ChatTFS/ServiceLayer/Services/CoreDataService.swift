import Foundation
import CoreData

protocol CoreDataServiceProtocol: AnyObject {
    func getChannelsFromDB() -> [ChannelNetworkModel]
    func getDBChannel(channel: String) -> ChannelNetworkModel
    func getMessagesFromDBChannel(channel: String) -> [MessageNetworkModel]
    func saveChannelsList(with channels: [ChannelNetworkModel])
    func updateChannel(for channel: ChannelNetworkModel)
    func deleteChannel(channelID: String)
    func saveMessagesForChannel(for channelID: String, messages: [MessageNetworkModel])
}

class CoreDataService: CoreDataServiceProtocol {
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Private properties
    
    let coreDataStack: CoreDataStackProtocol
    
    // MARK: - Public methods
    
    func getChannelsFromDB() -> [ChannelNetworkModel] {
        do {
            let dbChannels = try coreDataStack.fetchChannelsList()
            let channelsModel: [ChannelNetworkModel] = dbChannels
                .compactMap { channelsDB in
                    guard
                        let id = channelsDB.id,
                        let name = channelsDB.name
                    else {
                        return ChannelNetworkModel(id: "", name: "", logoURL: "", lastMessage: "", lastActivity: Date())
                    }
                    return ChannelNetworkModel(id: id,
                                               name: name,
                                               logoURL: nil,
                                               lastMessage: channelsDB.lastMessage,
                                               lastActivity: channelsDB.lastActivity)
                }
            return channelsModel
        } catch {
            print(error)
            return []
        }
    }
    
    func getDBChannel(channel: String) -> ChannelNetworkModel {
        do {
            let channelDB = try coreDataStack.fetchChannel(for: channel)
            guard let id = channelDB.id,
                  let name = channelDB.name
            else {
                return ChannelNetworkModel(id: "", name: "", logoURL: nil, lastMessage: nil, lastActivity: nil)
            }
            return ChannelNetworkModel(id: id,
                                       name: name,
                                       logoURL: channelDB.logoURL,
                                       lastMessage: channelDB.lastMessage,
                                       lastActivity: channelDB.lastActivity)
        } catch {
            return ChannelNetworkModel(id: "", name: "", logoURL: nil, lastMessage: nil, lastActivity: nil)
        }
    }
    
    func saveChannelsList(with channels: [ChannelNetworkModel]) {
        for channel in channels {
            coreDataStack.save { context in
                let channelManagedObject = DBChannel(context: context)
                channelManagedObject.id = channel.id
                channelManagedObject.name = channel.name
                channelManagedObject.lastActivity = channel.lastActivity
                channelManagedObject.lastMessage = channel.lastMessage
                channelManagedObject.messages = NSOrderedSet()
            }
        }
    }
    
    func updateChannel(for channel: ChannelNetworkModel) {
        do {
            let DBChannel = try coreDataStack.fetchChannel(for: channel.id)
            coreDataStack.update(channel: DBChannel) {
                DBChannel.lastActivity = channel.lastActivity
                DBChannel.lastMessage = channel.lastMessage
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteChannel(channelID: String) {
        do {
            let DBChannel = try coreDataStack.fetchChannel(for: channelID)
            let channelContext = DBChannel.managedObjectContext
            guard let channelContext else { return }
            channelContext.delete(DBChannel)
            try channelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func getMessagesFromDBChannel(channel: String) -> [MessageNetworkModel] {
        do {
            let messagesDB = try coreDataStack.fetchChannelMessages(for: channel)
            let messages: [MessageNetworkModel] = messagesDB
                .compactMap { messagesBD in
                    guard
                        let id = messagesBD.id,
                        let text = messagesBD.text,
                        let userID = messagesBD.userID,
                        let userName = messagesBD.userName,
                        let date = messagesBD.date
                    else {
                        return MessageNetworkModel()
                    }
                    return MessageNetworkModel(id: id,
                                               text: text,
                                               userID: userID,
                                               userName: userName,
                                               date: date)
                }
            return messages
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func saveMessagesForChannel(for channelID: String, messages: [MessageNetworkModel]) {
        coreDataStack.save { context in
            let fetchRequest = DBChannel.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelID)
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            guard
                let channelManagedObject
            else {
                return
            }
            
            for message in messages {
                let messageManagedObject = DBMessage(context: context)
                messageManagedObject.id = message.id
                messageManagedObject.date = message.date
                messageManagedObject.text = message.text
                messageManagedObject.userID = message.userID
                messageManagedObject.userName = message.userName
                channelManagedObject.lastMessage = message.text
                channelManagedObject.lastActivity = message.date
                channelManagedObject.addToMessages(messageManagedObject)
            }
            
            channelManagedObject.lastMessage = messages.last?.text
            channelManagedObject.lastActivity = messages.last?.date
        }
    }
}
