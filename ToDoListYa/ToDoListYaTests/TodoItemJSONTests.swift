import XCTest
@testable import ToDoListYa

final class TodoItemJSONTests: XCTestCase {
    
    var sut: TodoItem!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TodoItem(text: "testable")
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    // MARK: - tests FROM JSON
    func testParseEmptyJSON() {
        // GIVEN
        let json = ""
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, nil, "It should return nil")
    }
    
    func testParseWrongFormatJSON() {
        // GIVEN
        let json = TestData.ParseFromJSON.wrongFormat
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, nil, "It should return nil")
    }
    
    func testParseCorrectFormatJSON() {
        // GIVEN
        let json = TestData.ParseFromJSON.correctFormat
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        let resultCorrect = TestData.ParseFromJSON.correctResultFromJSON
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithOrdinaryPriority() {
        // GIVEN
        let json = TestData.ParseFromJSON.ordinaryPriority
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        let resultCorrect = TestData.ParseFromJSON.correctResultWithOrdinaryPriority
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithAnotherPriority() {
        // GIVEN
        let json = TestData.ParseFromJSON.importantPriority
        let resultCorrect = TestData.ParseFromJSON.correctResultWithImportantPriority
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithDeadline() {
        // GIVEN
        let json = TestData.ParseFromJSON.taskWithDeadline
        let resultCorrect = TestData.ParseFromJSON.correctResultWithDeadline
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithoutDeadline() {
        // GIVEN
        let json = TestData.ParseFromJSON.taskWithoutDeadline
        let resultCorrect = TestData.ParseFromJSON.correctResultWithoutDeadline
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithEditDate() {
        // GIVEN
        let json = TestData.ParseFromJSON.taskWithEditDate
        let resultCorrect = TestData.ParseFromJSON.correctResultWithEditDate
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    func testParseJSONWithoutEditDate() {
        // GIVEN
        let json = TestData.ParseFromJSON.taskWithoutEditDate
        let resultCorrect = TestData.ParseFromJSON.correctResultWithoutEditDate
        // WHEN
        let result = TodoItem.parseFrom(json: json)
        // THEN
        XCTAssertEqual(result, resultCorrect)
    }
    
    // MARK: - tests TO JSON
    
    func testTaskWithOrdinaryPriority() {
        // GIVEN
        let task = TestData.TestToJSON.ordinaryTask
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultOrdinaryPriority
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"]  as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["priority"] as? String, nil)
    }
    
    func testTaskWithAnotherPriority() {
        // GIVEN
        let task = TestData.TestToJSON.importantTask
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultImportantTask
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"] as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["priority"] as? String, correctResult["priority"] as? String)
    }
    
    func testTaskWithDeadline() {
        // GIVEN
        let task = TestData.TestToJSON.taskWithDeadline
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultWithDeadline
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"] as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["deadline"] as? Double, correctResult["deadline"] as? Double)
    }
    
    func testTaskWithoutDeadline() {
        // GIVEN
        let task = TestData.TestToJSON.taskWithoutDeadline
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultWithoutDeadline
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"] as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["deadline"] as? Double, correctResult["deadline"] as? Double)
    }
    
    func testTaskWithEditDate() {
        // GIVEN
        let task = TestData.TestToJSON.taskWithEditDate
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultWithEditDate
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"] as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["taskEditDate"] as? Double, correctResult["taskEditDate"] as? Double)
    }
    
    func testTaskWithoutEditDate() {
        // GIVEN
        let task = TestData.TestToJSON.taskWithoutEditDate
        // WHEN
        let result = task.json as? [String: AnyObject]
        let correctResult = TestData.TestToJSON.correctResultWithoutEditDate
        // THEN
        XCTAssertEqual(result?["id"] as? String, correctResult["id"] as? String)
        XCTAssertEqual(result?["text"] as? String, correctResult["text"] as? String)
        XCTAssertEqual(result?["taskDone"] as? Bool, correctResult["taskDone"] as? Bool)
        XCTAssertEqual(result?["taskStartDate"] as? Double, correctResult["taskStartDate"] as? Double)
        XCTAssertEqual(result?["taskEditDate"] as? Double, correctResult["taskEditDate"] as? Double)
    }
}

// MARK: - TestData
private extension TodoItemJSONTests {
    enum TestData {
        enum ParseFromJSON {
            static let wrongFormat = ["test", "test", "test" ]
            
            static let correctFormat = ["taskDone": false, "taskStartDate": 1686688574.6899471, "id": "C106", "text": "2222"] as [String: Any]
            
            static let correctResultFromJSON = TodoItem(id: "C106",
                                                        text: "2222",
                                                        priority: "ordinary",
                                                        taskDone: false,
                                                        taskStartDate: 1686688574.6899471)
            
            static let ordinaryPriority: [String: Any] = ["taskDone": true,
                                                           "taskStartDate": 1686688574.6899471,
                                                           "id": "1111",
                                                           "text": "test"]
            
            static let correctResultWithOrdinaryPriority = TodoItem(id: "1111",
                                                                    text: "test",
                                                                    priority: "ordinary",
                                                                    taskDone: true,
                                                                    taskStartDate: 1686688574.6899471)
            
            static let importantPriority: [String: Any] = ["taskDone": true,
                                                            "taskStartDate": 1686688574.6899471,
                                                            "id": "1111",
                                                            "text": "test",
                                                            "priority": "important"]
            
            static let correctResultWithImportantPriority = TodoItem(id: "1111",
                                                                     text: "test",
                                                                     priority: "important",
                                                                     taskDone: true,
                                                                     taskStartDate: 1686688574.6899471)
            static let taskWithDeadline: [String: Any] = ["taskDone": false,
                                                           "taskStartDate": 1686688574.6899471,
                                                           "id": "2D",
                                                           "text": "2222",
                                                           "deadline": 1686688574.6899471]
            
            static let correctResultWithDeadline = TodoItem(id: "2D",
                                                            text: "2222",
                                                            priority: "ordinary",
                                                            taskDone: false,
                                                            deadline: 1686688574.6899471,
                                                            taskStartDate: 1686688574.6899471)
            
            static let taskWithoutDeadline: [String: Any] = ["taskDone": false,
                                                              "taskStartDate": 1686688574.6899471,
                                                              "id": "2D",
                                                              "text": "2222"]
            
            static let  correctResultWithoutDeadline = TodoItem(id: "2D",
                                                                text: "2222",
                                                                priority: "ordinary",
                                                                taskDone: false,
                                                                taskStartDate: 1686688574.6899471)
            
            static let taskWithEditDate: [String: Any] = ["taskDone": false,
                                                            "taskStartDate": 1686688574.6899471,
                                                            "id": "2D",
                                                            "text": "2222",
                                                            "taskEditDate": 1686688574.6899471]
            
            static let  correctResultWithEditDate = TodoItem(id: "2D",
                                                             text: "2222",
                                                             priority: "ordinary",
                                                             taskDone: false,
                                                             taskStartDate: 1686688574.6899471,
                                                             taskEditDate: 1686688574.6899471)
            
            static let taskWithoutEditDate: [String: Any] = ["taskDone": false,
                                                               "taskStartDate": 1686688574.6899471,
                                                               "id": "2D",
                                                               "text": "2222"]
            
            static let correctResultWithoutEditDate = TodoItem(id: "2D",
                                                               text: "2222",
                                                               priority: "ordinary",
                                                               taskDone: false,
                                                               taskStartDate: 1686688574.6899471)
            
        }
        
        enum TestToJSON {
            static let ordinaryTask = TodoItem(id: "2D",
                                               text: "2222",
                                               priority: "ordinary",
                                               taskDone: false,
                                               taskStartDate: 1686688574.6899471)
            
            static let correctResultOrdinaryPriority: [String: Any] = ["id": "2D",
                                                                        "text": "2222",
                                                                        "taskDone": false,
                                                                        "taskStartDate": 1686688574.6899471]
            
            static let importantTask = TodoItem(id: "2D",
                                                text: "2222",
                                                priority: "important",
                                                taskDone: false,
                                                taskStartDate: 1686688574.6899471)
            
            static let correctResultImportantTask: [String: Any] = ["id": "2D",
                                                                     "text": "2222",
                                                                     "taskDone": false,
                                                                     "priority": "important",
                                                                     "taskStartDate": 1686688574.6899471]
            
            static let taskWithDeadline = TodoItem(id: "2D",
                                                   text: "2222",
                                                   priority: "ordinary",
                                                   taskDone: false,
                                                   deadline: 1686688574.6899471,
                                                   taskStartDate: 1686688574.6899471)
            
            static let correctResultWithDeadline: [String: Any] = ["id": "2D",
                                                                    "text": "2222",
                                                                    "taskDone": false,
                                                                    "deadline": 1686688574.6899471,
                                                                    "taskStartDate": 1686688574.6899471]
            
            static let taskWithoutDeadline = TodoItem(id: "2D",
                                                      text: "2222",
                                                      priority: "ordinary",
                                                      taskDone: false,
                                                      taskStartDate: 1686688574.6899471)
            
            static let correctResultWithoutDeadline: [String: Any] = ["id": "2D",
                                                                       "text": "2222",
                                                                       "taskDone": false,
                                                                       "taskStartDate": 1686688574.6899471]
            
            static let taskWithEditDate = TodoItem(id: "2D",
                                                   text: "2222",
                                                   priority: "ordinary",
                                                   taskDone: false,
                                                   taskStartDate: 1686688574.6899471,
                                                   taskEditDate: 1686688574.6899471)
            
            static let correctResultWithEditDate: [String: Any] = ["id": "2D",
                                                                    "text": "2222",
                                                                    "taskDone": false,
                                                                    "taskStartDate": 1686688574.6899471,
                                                                    "taskEditDate": 1686688574.6899471]
            
            static let taskWithoutEditDate = TodoItem(id: "2D",
                                                      text: "2222",
                                                      priority: "ordinary",
                                                      taskDone: false,
                                                      taskStartDate: 1686688574.6899471)
            
            static let correctResultWithoutEditDate: [String: Any] = ["id": "2D",
                                                                       "text": "2222",
                                                                       "taskDone": false,
                                                                       "taskStartDate": 1686688574.6899471]
        }
    }
}
