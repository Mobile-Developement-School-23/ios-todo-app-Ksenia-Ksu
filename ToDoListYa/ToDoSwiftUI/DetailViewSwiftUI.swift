import SwiftUI

struct DetailViewSwiftUI: View {
    @State var item: TodoItemMock
    @State private var text: String = ""
    var body: some View {
            VStack {
                TopStack()
                TextEditor(text: $text)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    .frame(height: 300)
            
                VStack {
                    PriorityView()
                    DeadlineView(deadline: item.deadline?.timeInSecondsToDateString())
                }
                .background(.white)
                .padding()
             
                Spacer()
                Button(action: {
                    print("save")
                })  {
                    Text("Удалить")
                }
                .foregroundColor(.red)
              
                Spacer()
            } .background(Color(ThemeColors.backPrimary!))
    }
}

struct TopStack: View {
    var body: some View {
        HStack {
            Button(action: {
                print("cancel")
            })  {
                Text("Отменить")
            }
            .tint(.blue)
            Spacer()
            Text("Дело")
            Spacer()
            Button(action: {
                print("save")
            })  {
                Text("Сохранить")
            }
            .tint(.blue)
        }
        .padding()
    }
}

struct PriorityView: View {
    @State private var selectionPriority: Priority = .basic
    var body: some View {
        HStack() {
            Text("Важность")
            Spacer()
            Picker("", selection: $selectionPriority) {
                    Image(Priority.low.rawValue)
                    Text("нет")
                    Image("high")
                
            }
            .frame(width: 150, height: 60)
            .pickerStyle(SegmentedPickerStyle())
        } .padding()
    }
}

enum Priority: String, CaseIterable {
    case low
    case basic
    case important
}

struct DeadlineView: View {
    @State private var isCalendarShow = false
    @State var deadline: String?
    var body: some View {
        HStack {
            VStack(alignment: .leading , spacing: 5) {
                Text("Сделать до")
                Button(action: {
                    print("deadline")
                })  {
                    if deadline != nil {
                        Text(deadline!)
                    }
                }
                .tint(.blue)
            }
            Toggle(isOn: $isCalendarShow) {
               
            }.toggleStyle( SwitchToggleStyle(tint: .green))
        } .padding()
    }
}

struct DetailViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        DetailViewSwiftUI(item: itemsMocks[0])
    }
}
