import SwiftUI

struct TodoList: View {
    @State var items: [TodoItemMock] = itemsMocks
    var body: some View {
        NavigationStack {
            List {
                Section(header: ListHeader()) {
                    ForEach(items, id: \.id) { item in
                        NavigationLink {
                            DetailViewSwiftUI(item: item)
                        } label: {
                            ListCell(item: item)
                        }

                      
                    }
                    .onDelete(perform: deleteItem)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        
                        Button(action: {
                            print("left")
                        })  {
                            Image("propGreenCheckmark")
                        } .tint(.green)
                    }
                    
                }
            }
            .navigationTitle(Text("Мои дела"))
        }
    }
    
    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
}

struct ListHeader: View {
    var body: some View {
        HStack {
            Text("Выполнено - 0")
                .font(.system(size: 15))
            Spacer()
            Button("Показать") {
                print("Show")
            }
        }
    }
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
        TodoList(items: itemsMocks)
    }
}


