//
//  ListCell.swift
//  ToDoSwiftUI
//
//  Created by Ксения Кобак on 17.07.2023.
//

import SwiftUI

struct ListCell: View {
    var item: TodoItemMock
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                print("Text")
            })  {
                Image("propOff")
            }
            if item.priority == TaskPriority.important.rawValue {   Image("high")
            } else if item.priority == TaskPriority.low.rawValue {
                Image("low")
            } 
         
            VStack(alignment: .leading, spacing: 3) {
                Text(item.text)
                    .lineLimit(3)
                    .font(.system(size: Layout.taskFont))
                HStack {
                    if let deadline = item.deadline {
                        Image("calendar")
                        Text(deadline.timeInSecondsToDateString())
                            .font(.system(size: Layout.deadlineFont))
                    }
                }
            }
      
           
        }
    }
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(item: itemsMocks[0])
    }
}

extension ListCell {
    enum Layout {
        static let taskFont: CGFloat = 17
        static let deadlineFont: CGFloat = 15
    }
    
}
