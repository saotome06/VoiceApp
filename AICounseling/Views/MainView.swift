import SwiftUI

struct MainView: View {
    @State private var isMenuOpen = false
    
    var body: some View {
        ContentViewWithMenu {
            TopView()
        }
        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
    }}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
