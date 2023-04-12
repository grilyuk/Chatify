import Foundation
import CoreData

protocol CoreDataServiceProtocol: AnyObject {
    
    func fetchChannelsList() throws -> [DBChannel]
    func fetchChannel(for channelID: String) throws -> DBChannel
    func fetchChannelMessages(for channelID: String) throws -> [DBMessage]
    func save(block: (NSManagedObjectContext) throws -> Void )
    func clearMessagesData()
    func clearEntitiesData(entity: String)
}

class CoreDataService: CoreDataServiceProtocol {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Chat")
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
            print(error)
        }
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func fetchChannelsList() throws -> [DBChannel] {
        let fetchRequest = DBChannel.fetchRequest()
        return try viewContext.fetch(fetchRequest)
    }
    
    func fetchChannel(for channelID: String) throws -> DBChannel {
        let fetchRequest = DBChannel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        let DBChannell = try viewContext.fetch(fetchRequest).first
        guard
            let DBChannell
        else {
            print("fail")
            return DBChannel(context: viewContext)
        }
        print("success")
        return DBChannell
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
    
    func save(block: (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func clearEntitiesData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            print("Чистим чистим...")
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func clearMessagesData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DBMessage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            print("Чистим чистим...")
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}
