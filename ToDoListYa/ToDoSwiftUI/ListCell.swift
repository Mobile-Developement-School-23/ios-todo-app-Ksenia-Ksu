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
            Image("high")
            VStack(alignment: .leading, spacing: 3) {
                Text(item.text)
                    .lineLimit(3)
                HStack {
                    if item.deadline != nil {
                        Image("calendar")
                        Text("deadline")
                    }
                }
            }
            Spacer()
            Image("arrowRight")
        }
    }
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(item: items[0])
    }
}
