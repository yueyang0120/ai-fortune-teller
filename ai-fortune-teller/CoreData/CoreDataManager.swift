import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "ZiWeiFortune")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        #if DEBUG
        print("CoreData initialized")
        print("Store URL: \(String(describing: container.persistentStoreCoordinator.persistentStores.first?.url))")
        #endif
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
                #if DEBUG
                print("CoreData saved successfully")
                #endif
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        context.perform {
            task(context)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    print("Background save error: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    /// Async version with completion callback — use when you need to know the save finished
    func performBackgroundTaskAsync(_ task: @escaping (NSManagedObjectContext) -> Void, completion: @escaping () -> Void) {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        context.perform {
            task(context)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    print("Background save error: \(nsError), \(nsError.userInfo)")
                }
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    // Helper method to fetch all readings
    func fetchAllReadings() throws -> [ReadingHistoryEntity] {
        let fetchRequest: NSFetchRequest<ReadingHistoryEntity> = ReadingHistoryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ReadingHistoryEntity.createdAt, ascending: false)]
        return try context.fetch(fetchRequest)
    }

    // Helper method to delete a reading
    func deleteReading(_ reading: ReadingHistoryEntity) {
        context.delete(reading)
        save()
    }

    // Helper method to delete all readings
    func deleteAllReadings() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ReadingHistoryEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: context)
            try context.save()
            #if DEBUG
            print("All readings deleted successfully")
            #endif
        } catch {
            print("Failed to delete all readings: \(error)")
        }
    }
}
