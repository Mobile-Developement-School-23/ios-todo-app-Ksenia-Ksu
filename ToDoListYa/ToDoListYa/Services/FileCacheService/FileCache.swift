import Foundation
import ToDoItemModule

protocol FileCaching {
    var toDoItems: [TodoItem] { get }
    func addTask (task: TodoItem)
    func deleteTask(with id: String) -> TodoItem?
    func saveAllTasksToJSONFile(named: String)
    func load(named: String, completion: @escaping (Result<[TodoItem], Error>) -> Void)
    // func loadTasksFromJSONFile(named: String) -> [TodoItem]?
    func saveAllTasksToCSVFile(named: String)
    func loadTasksFromCSVFile(named: String) -> [TodoItem]?
    func reloadTasks()
}

final class FileCache: FileCaching {
   
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "Queue")
    
    private(set) var toDoItems: [TodoItem] = []
    
    func addTask(task: TodoItem) {
        if let index = toDoItems.firstIndex(where: {$0.id == task.id }) {
            toDoItems[index] = task
        } else {
            toDoItems.append(task)
        }
    }
    @discardableResult
    func deleteTask(with id: String) -> TodoItem? {
        if let index = toDoItems.firstIndex(where: {$0.id == id }) {
            return toDoItems.remove(at: index)
        }
        return nil
    }
    
    // MARK: - JSON
    // MARK: - Save
    func saveAllTasksToJSONFile(named: String) {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let documentsDirectoryPath = URL(fileURLWithPath: url.path)
        let pathSearch = documentsDirectoryPath.appendingPathComponent("\(named).json")
        if !fileManager.fileExists(atPath: pathSearch.path) {
            fileManager.createFile(atPath: pathSearch.path, contents: nil)
        }
        writeToJSONFileAt(fileUrl: pathSearch)
    }
    
    @discardableResult
    func loadTasksFromJSONFile(named: String) -> [TodoItem]? {
        var items: [TodoItem] = []
        
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        
        let documentsDirectoryPath = URL(fileURLWithPath: url.path)
        let pathSearch = documentsDirectoryPath.appendingPathComponent("\(named).json")
        do {
            let data = try Data(contentsOf: pathSearch)
            guard let jsonObject =  try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return nil }
            for item in jsonObject {
                if let newItem = TodoItem.parseFrom(json: item) {
                    items.append(newItem)
                }
            }
        } catch let error as NSError {
            print("Error if loading json file: \(error.localizedDescription)")
        }
        toDoItems = items
        return items
    }
    
    func load(named: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        queue.async {
            var items: [TodoItem] = []
            
            guard let url = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return}
            
            let documentsDirectoryPath = URL(fileURLWithPath: url.path)
            let pathSearch = documentsDirectoryPath.appendingPathComponent("\(named).json")
            do {
                let data = try Data(contentsOf: pathSearch)
                guard let jsonObject =  try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
                for item in jsonObject {
                    if let newItem = TodoItem.parseFrom(json: item) {
                        items.append(newItem)
                    }
                }
                self.toDoItems = items
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print("Error if loading json file: \(error.localizedDescription)")
            }
        }
    }
    
    private func writeToJSONFileAt(fileUrl: URL) {
        var dict: [[String: Any]] = []
        for item in toDoItems {
            if let newItem = item.json as? [String: Any] {
                dict.append(newItem)
            }
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            try data.write(to: fileUrl, options: [])
        } catch {
            print("Error of savingData to JSON file \(error.localizedDescription)")
        }
    }
    
    func reloadTasks() {
        toDoItems = []
    }
    
    // MARK: - Save And Load CSV
    func saveAllTasksToCSVFile(named: String) {
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("\(named).csv")
            // заголовки для CSV файла
            var csvString = CSVText.headers
            for item in toDoItems {
                csvString += item.csv
            }
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating CSVfile: \(error.localizedDescription)")
        }
    }
    
    func loadTasksFromCSVFile(named: String) -> [TodoItem]? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        let CSVDirectoryPath = URL(fileURLWithPath: url.path)
        let pathSearch = CSVDirectoryPath.appendingPathComponent("\(named).csv")
        do {
            let data = try String(contentsOf: pathSearch)
            let items = TodoItem.parseFromCSVFormat(csv: data)
            toDoItems = items
            return items
        } catch {
            print("error loading CSVfile: \(error.localizedDescription)")
            return nil
        }
    }
    
}
