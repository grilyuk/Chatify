import Foundation
import CoreData

protocol CoreDataServiceProtocol: AnyObject {
    
    func fetchChannelsList() throws -> [DBChannel]
    func fetchChannel(for channelID: String) throws -> DBChannel
    func fetchChannelMessages(for channelID: String) throws -> [DBMessage]
    func save(loggerText: String, block: @escaping (NSManagedObjectContext) throws -> Void )
    func deleteObject(loggerText: String, channelID: String)
    func clearEntitiesData(entity: String)
}

class CoreDataService: CoreDataServiceProtocol {
    
    var logger = Logger()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Chat")
        persistentContainer.loadPersistentStores { [weak self] _, error in
            guard let error else { return }
            self?.logger.displayLog(result: .failure, isMainThread: Thread.isMainThread,
                                    activity: "PersistentContainer not loaded: error: \(error.localizedDescription)")
        }
        logger.displayLog(result: .success, isMainThread: Thread.isMainThread,
                                activity: "PersistentContainer loaded")
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func fetchChannelsList() throws -> [DBChannel] {
        let fetchRequest = DBChannel.fetchRequest()
        let loggerText = "DBChannels fetching"
        do {
            let request = try viewContext.fetch(fetchRequest)
            logger.displayLog(result: .success, isMainThread: Thread.isMainThread, activity: loggerText)
            return request
        } catch {
            logger.displayLog(result: .failure, isMainThread: Thread.isMainThread, activity: loggerText)
            return [DBChannel()]
        }
    }
    
    func fetchChannel(for channelID: String) throws -> DBChannel {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        let DBChannelObject = try viewContext.fetch(fetchRequest).first
        guard
            let DBChannelObject,
            let id = DBChannelObject.id
        else {
            logger
                .displayLog(result: .failure, isMainThread: Thread.isMainThread, activity: "DBChannel fetching")
            return DBChannel()
        }
        logger
            .displayLog(result: .success, isMainThread: Thread.isMainThread, activity: "DBChannel \(id) fetching")
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
    
    func save(loggerText: String, block: @escaping (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                    self.logger
                        .displayLog(result: .success, isMainThread: Thread.isMainThread, activity: loggerText)
                }
            } catch {
                self.logger
                    .displayLog(result: .failure, isMainThread: Thread.isMainThread, activity: loggerText)
            }
        }
    }
    
    func deleteObject(loggerText: String, channelID: String) {
        do {
            let DBChannel = try fetchChannel(for: channelID)
            let channelContext = DBChannel.managedObjectContext
            guard let channelContext else { return }
            channelContext.delete(DBChannel)
            logger.displayLog(result: .success, isMainThread: Thread.isMainThread, activity: loggerText)
            do {
                try channelContext.save()
                logger.displayLog(result: .success, isMainThread: Thread.isMainThread, activity: loggerText)
            } catch {
                logger.displayLog(result: .failure, isMainThread: Thread.isMainThread, activity: loggerText)
            }
        } catch {
            logger.displayLog(result: .failure, isMainThread: Thread.isMainThread, activity: loggerText)
        }
    }
    
    func clearEntitiesData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}
