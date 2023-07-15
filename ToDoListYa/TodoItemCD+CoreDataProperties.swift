import Foundation
import CoreData

extension TodoItemCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCD> {
        return NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var taskDone: Bool
    @NSManaged public var priority: String
    @NSManaged public var taskStartDate: String
    @NSManaged public var taskEditDate: String?
    @NSManaged public var deadline: String?
    @NSManaged public var hexColor: String?

}

extension TodoItemCD: Identifiable {

}
