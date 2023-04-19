import Foundation
import CoreData

protocol CoreDataStackProtocol {
    func fetchChannelsList() throws -> [DBChannel]
    func fetchChannel(for channelID: String) throws -> DBChannel
    func fetchChannelMessages(for channelID: String) throws -> [DBMessage]
    func save(block: @escaping (NSManagedObjectContext) throws -> Void)
    func update(channel: DBChannel, block: @escaping () throws -> Void)
}

final class CoreDataStack: CoreDataStackProtocol {
    
    // MARK: - Private properties
    
    private let dataModelName = "Chat"
    
    // MARK: - Public properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let persistentContainer = NSPersistentContainer(name: dataModelName)
        
        persistentContainer.loadPersistentStores { [weak self] _, error in
            guard let error else { return }
            print(error.localizedDescription)
        }
        return persistentContainer
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Public methods
    
    func save(block: @escaping (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchChannelsList() throws -> [DBChannel] {
        let fetchRequest = DBChannel.fetchRequest()
        do {
            let request = try viewContext.fetch(fetchRequest)
            return request
        } catch {
            return [DBChannel()]
        }
    }
    
    func fetchChannel(for channelID: String) throws -> DBChannel {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        let DBChannelObject = try viewContext.fetch(fetchRequest).first
        guard
            let DBChannelObject
        else {
            return DBChannel()
        }
        return DBChannelObject
    }
    
    func fetchChannelMessages(for channelID: String) throws -> [DBMessage] {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        let DBChannel = try viewContext.fetch(fetchRequest).first
        guard
            let DBChannel,
            let DBMessage = DBChannel.messages?.array as? [DBMessage]
        else {
            return []
        }
        
        return DBMessage
    }
    
    func update(channel: DBChannel, block: @escaping () throws -> Void) {
        guard let context = channel.managedObjectContext else { return }
        context.perform {
            do {
                try block()
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
