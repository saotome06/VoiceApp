import SwiftUI

let sampleCounselors = [
    Counselor(name: "alloy", voice: "alloy", profileIcon: "person.fill"),
    Counselor(name: "echo", voice: "echo", profileIcon: "person.fill"),
    Counselor(name: "fable", voice: "fable", profileIcon: "person.fill"),
    Counselor(name: "onyx", voice: "onyx", profileIcon: "person.fill"),
    Counselor(name: "nova", voice: "nova", profileIcon: "person.fill"),
    Counselor(name: "shimmer", voice: "shimmer", profileIcon: "person.fill")
]

struct CounselorListView: View {
    var counselors: [Counselor]
    
    var body: some View {
        NavigationView {
            List(counselors) { counselor in
                VoiceTalkDialogView(
                    iconName: "person.fill",
                    title: counselor.name,
                    description: counselor.voice,
                    counselor: counselor
                )
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
            .background(Color(red: 0.96, green: 0.98, blue: 0.92)) // 背景色を設定
        }
    }
}

struct VoiceTalkDialogView: View {
    var iconName: String
    var title: String
    var description: String
    var counselor: Counselor
    
    @State public var showModal = false
    @State private var selectedSystemContent: String?
    
    var body: some View {
        VStack {
            Button(action: {
                showModal = true
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: counselor.profileIcon)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(counselor.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(counselor.voice)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    NavigationLink(destination: VoiceChatWrapper(voice: counselor.voice, systemContent: selectedSystemContent), isActive: Binding<Bool>(
                        get: { selectedSystemContent != nil },
                        set: { if !$0 { selectedSystemContent = nil } }
                    )) {
                        EmptyView()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showModal) {
                TalkSelectionView { systemContent in
                    if systemContent != "" {
                        selectedSystemContent = systemContent
                    }
                    showModal = false
                }
            }
        }
        .padding(.vertical, 10)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CounselorListView_Previews: PreviewProvider {
    static var previews: some View {
        CounselorListView(counselors: sampleCounselors)
    }
}
