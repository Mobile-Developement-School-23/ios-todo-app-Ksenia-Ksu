import XCTest
@testable import ToDoListYa

final class TodoItemCSVTests: XCTestCase {
    
    func testParseToCSVWithOrdinaryPriority() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithOrdinaryPriority
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithOrdinaryPriority
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVWithAnotherPriority() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithAnotherPriority
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithAnotherPriority
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVDeadlineNil() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithDeadlineNil
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithDeadlineNil
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVDeadlineNotNil() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithDeadlineNotNil
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithDeadlineNotNil
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVEditDateNil() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithEditDateNil
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithEditDateNil
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVEditDateNotNil() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithEditDateNotNil
        //THEN
        let result = item.csv
        let correctResult = TestData.ParseToCSV.correctResultWithEditDateNotNil
        //WHEN
        XCTAssertEqual(result, correctResult)
    }
    
    func testParseToCSVWithCommaInField() {
        //GIVEN
        // Если в текстовом поле TodoItem.text будет запятая весь файл CSV слетит в кодироке
        //проверяю, соответствие количества запятых по количеству полей
        let item = TestData.ParseToCSV.itemWithCommaInText
        //THEN
        let result = item.csv.filter { $0 == ","}.count
        let correctResult = TestData.ParseToCSV.correctResultForiIemWithCommaInText.filter { $0 == ","}.count
        //WHEN
        XCTAssertEqual(result,correctResult )
    }
    
    func testParseToCSVWithoutCommaInField() {
        //GIVEN
        let item = TestData.ParseToCSV.itemWithoutCommaInText
        //THEN
        let result = item.csv.filter { $0 == ","}.count
        let correctResult = TestData.ParseToCSV.correctResultForiIemWithoutCommaInText.filter { $0 == ","}.count
        //WHEN
        XCTAssertEqual(result,correctResult)
    }
    
    func testParseFromCSVWithCorrectFieldsCount() {
        //GIVEN
        let string = TestData.ParseFromCSV.correctFieldsCount
        //THEN
        let result = TodoItem.parseFromCSVFormat(csv: string)
        //WHEN
        XCTAssertEqual(result,TestData.ParseFromCSV.correctResult)
    }
    
    func testParseFromCSVWithWrongFieldsCount() {
        //GIVEN
        let string = TestData.ParseFromCSV.wrongFielsdCount
        //THEN
        let result = TodoItem.parseFromCSVFormat(csv: string)
        //WHEN
        XCTAssertEqual(result,[])
    }
    
    func testParseFromCSVWithEmptyString() {
        //GIVEN
        let string = ""
        //THEN
        let result = TodoItem.parseFromCSVFormat(csv: string)
        //WHEN
        XCTAssertEqual(result,[])
    }
}

extension TodoItemCSVTests {
    enum TestData {
        enum ParseToCSV {
            static let itemWithOrdinaryPriority = TodoItem(id:"11111", text: "test", priority: "ordinary", deadline: 849323737.33333, taskStartDate: 646776000.0)
            static let correctResultWithOrdinaryPriority = "11111,test, ,no,1996-11-30,1990-07-01, \n"
            
            
            static let itemWithAnotherPriority = TodoItem(id:"11111", text: "test", priority: "important", deadline: 849323737.33333, taskStartDate: 646776000.0)
            static let correctResultWithAnotherPriority = "11111,test,important,no,1996-11-30,1990-07-01, \n"
            
            
            static let itemWithDeadlineNil = TodoItem(id:"11111", text: "test", priority: "important", taskStartDate: 646776000.0)
            static let correctResultWithDeadlineNil = "11111,test,important,no, ,1990-07-01, \n"
            
            
            static let itemWithDeadlineNotNil = TodoItem(id:"11111", text: "test", priority: "important",deadline: 849323737.33333,taskStartDate: 646776000.0)
            static let correctResultWithDeadlineNotNil = "11111,test,important,no,1996-11-30,1990-07-01, \n"
            
            
            static let itemWithEditDateNil = TodoItem(id:"11111", text: "test", priority: "important", taskStartDate: 646776000.0)
            static let correctResultWithEditDateNil = "11111,test,important,no, ,1990-07-01, \n"
            
            
            static let itemWithEditDateNotNil = TodoItem(id:"11111", text: "test", priority: "important", taskStartDate: 646776000.0, taskEditDate: 849323737.33333)
            static let correctResultWithEditDateNotNil = "11111,test,important,no, ,1990-07-01,1996-11-30\n"
        
            
            static let itemWithCommaInText = TodoItem(id:"F01405EF-9725-41C4-9410-D23B24AF72C6", text: "test1,00", deadline: 849323737.33333, taskStartDate: 646776000.0)
            static let correctResultForiIemWithCommaInText = "F01405EF-9725-41C4-9410-D23B24AF72C6,test1 00, ,no,1996-11-30,1990-07-01, \n"
            
            static let itemWithoutCommaInText = TodoItem(id:"F01405EF-9725-41C4-9410-D23B24AF72C6", text: "test1 00", deadline: 849323737.33333,taskStartDate: 646776000.0)
            static let correctResultForiIemWithoutCommaInText = "F01405EF-9725-41C4-9410-D23B24AF72C6,test1 00, ,no,1996-11-30,1990-07-01, \n"
        }
        enum ParseFromCSV {
            static let wrongFielsdCount = "F01405EF-9725-41C4-9410-D23B24AF72C6,test1 00, ,no,1996-11-30,2023-06-16, ,2023-06-16, \n"
            static let correctFieldsCount = "ID,Task description,Task priority,Is done,DeadLine,Task start,Task was edited\nF01405EF-9725-41C4-9410-D23B24AF72C6,test1 00, ,no,2020-11-30,2021-06-16, \n"
            static let correctResult = [TodoItem(id: "F01405EF-9725-41C4-9410-D23B24AF72C6", text: "test1 00", priority: "ordinary", taskDone: false, deadline: 1606683600.0, taskStartDate: 1623790800.0, taskEditDate: nil)]
        }
    }
}
