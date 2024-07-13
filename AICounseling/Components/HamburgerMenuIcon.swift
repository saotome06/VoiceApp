import SwiftUI

struct HamburgerMenuIcon: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Capsule()
                .fill(Color.gray)
                .frame(width: 25, height: 3)
                .rotationEffect(Angle(degrees: isOpen ? 45 : 0), anchor: .leading)
                .offset(x: isOpen ? 2 : 0, y: isOpen ? 6 : 0)
            
//            Capsule()
//                .fill(Color.white)
//                .frame(width: 30, height: 3)
//                .opacity(isOpen ? 0 : 1)
//                .scaleEffect(isOpen ? 0.5 : 1)
            
            Capsule()
                .fill(Color.gray)
                .frame(width: 30, height: 3)
                .rotationEffect(Angle(degrees: isOpen ? -45 : 0), anchor: .leading)
                .offset(x: isOpen ? 2 : 0, y: isOpen ? -6 : 0)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0), value: isOpen)
    }
}

struct CircularHamburgerMenuIcon: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
            
            HamburgerMenuIcon(isOpen: $isOpen)
        }
    }
}
