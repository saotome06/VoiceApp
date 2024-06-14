import SwiftUI

struct MainView: View {
    @State private var isMenuOpen = false
    
    var body: some View {
        ContentViewWithMenu {
            TopView()
        }
        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
        .background(Color(red: 0.96, green: 0.98, blue: 0.92))
    }}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
