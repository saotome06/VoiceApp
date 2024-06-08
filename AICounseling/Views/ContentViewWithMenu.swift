import SwiftUI

struct ContentViewWithMenu<Content: View>: View {
    @State private var isMenuOpen = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    content
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: isMenuOpen ? geometry.size.width * 0.6 : 0)
                        .disabled(isMenuOpen) // メニューが開いているときはメインビューの操作を無効化
                        .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                    
                    if isMenuOpen {
                        SideMenuView(isMenuOpen: $isMenuOpen)
                            .frame(width: geometry.size.width * 0.6)
                            .transition(.move(edge: .leading))
                            .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 100 {
                                withAnimation {
                                    isMenuOpen = true
                                }
                            } else if value.translation.width < -100 {
                                withAnimation {
                                    isMenuOpen = false
                                }
                            }
                        }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
    }
}

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuItem(iconName: "person.fill", title: "ログイン", destination: LoginView())
            MenuItem(iconName: "house.fill", title: "ホーム", destination: MainView())
            MenuItem(iconName: "heart.fill", title: "カウンセラー", destination: CounselorListView(counselors: sampleCounselors))
            MenuItem(iconName: "face.smiling", title: "表情認識", destination: PyFeatView())
            Spacer()
        }
        .padding(.top, 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .onTapGesture {
            withAnimation {
                isMenuOpen = false
            }
        }
    }
}

struct MenuItem<Destination: View>: View {
    var iconName: String
    var title: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium, design: .default))
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
