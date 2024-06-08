import SwiftUI

let sampleCounselors = [
    Counselor(name: "Alice", status: "Online", profileIcon: "person.fill"),
    Counselor(name: "Bob", status: "Offline", profileIcon: "person.fill"),
    Counselor(name: "Charlie", status: "Busy", profileIcon: "person.fill")
]

struct CounselorDetailView: View {
    var counselor: Counselor
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 120, height: 120)
                
                Image(systemName: counselor.profileIcon)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
            }
            .shadow(radius: 10)
            .padding(.bottom, 20)
            
            Text(counselor.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(counselor.status)
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationTitle(counselor.name)
    }
}

struct CounselorListView: View {
    var counselors: [Counselor]
    
    var body: some View {
        NavigationView {
            List(counselors) { counselor in
                NavigationLink(destination: TextChat()) {
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
                            
                            Text(counselor.status)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.vertical, 10)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
        }
    }
}

struct CounselorListView_Previews: PreviewProvider {
    static var previews: some View {
        CounselorListView(counselors: sampleCounselors)
    }
}
