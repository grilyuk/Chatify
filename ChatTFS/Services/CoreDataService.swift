import Foundation
import CoreData

protocol CoreDataServiceProtocol: AnyObject {
    
    func fetchChannelsList() throws -> [DBChannel]
    func save(block: (NSManagedObjectContext) throws -> Void )
    func clearAllData()
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
    
    func clearAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DBChannel")
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
