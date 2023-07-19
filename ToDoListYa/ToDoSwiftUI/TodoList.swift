import SwiftUI

struct TodoList: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: ListHeader()) {
                    ForEach(items) { item in
                        ListCell(item: item)
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
            Spacer()
            Button("Показать") {
                print("Show")
            }
        }
    }
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
        TodoList()
    }
}
