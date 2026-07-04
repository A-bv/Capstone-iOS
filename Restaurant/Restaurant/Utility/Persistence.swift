import CoreData
import Foundation
import OSLog

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Restaurant", category: "Persistence")

    // Load the model exactly once and share it, so instantiating more than one
    // container (e.g. in-memory stores in tests) doesn't reload it and leave
    // Core Data unable to match `Dish` to a single entity description.
    // nonisolated(unsafe): an NSManagedObjectModel is immutable once built and
    // safe to read from any thread, but it isn't marked Sendable by Core Data.
    private nonisolated(unsafe) static let model: NSManagedObjectModel = {
        guard let url = Bundle(for: Dish.self).url(forResource: "ExampleDatabase", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Missing Core Data model 'ExampleDatabase'")
        }
        return model
    }()

    /// - Parameter inMemory: when true, backs the store with /dev/null so tests
    ///   and previews get a fresh, disposable store instead of the on-disk cache.
    init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: "ExampleDatabase", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            guard let error else { return }

            // The store holds only the re-downloadable menu cache, so a load
            // failure (a corrupt or un-migratable store) is recoverable: log it,
            // destroy the store, and try once more.
            Self.logger.fault("Store failed to load: \(error.localizedDescription, privacy: .public). Rebuilding.")

            guard !inMemory, let url = description.url else {
                assertionFailure("Unrecoverable Core Data store error: \(error)")
                return
            }
            // Best-effort: if this fails, the reload below surfaces the problem.
            try? container.persistentStoreCoordinator.destroyPersistentStore(at: url, type: .sqlite)
            container.loadPersistentStores { _, retryError in
                if let retryError {
                    Self.logger.fault("Store still failed after rebuild: \(retryError.localizedDescription, privacy: .public).")
                    assertionFailure("Unrecoverable Core Data store error: \(retryError)")
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}
