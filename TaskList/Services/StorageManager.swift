//
//  StorageManager.swift
//  TaskList
//
//  Created by 1234 on 04.04.2023.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func createTask(taskName: String, compliition: (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task",
                                                                 in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription,
                                         insertInto: context) as? Task else { return }
        task.title = taskName
        compliition(task)
        saveContext()
    }
    
    func fetchData(complition: (Result<[Task], Error>) ->Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            complition(.success(tasks))
        } catch let error{
            complition(.failure(error))
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
