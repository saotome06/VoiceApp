import SwiftUI

struct TopView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: LoginView()) {
                        Text("ログイン")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                Image("profile_picture") // プロフィール画像
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 10)
                    .padding(.top, 30)
                
                Spacer()
                
                VStack {
                    Text("John Doe") // ユーザー名
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    ProgressBar(progress: 0.5) // 進捗バー、0.5で50%の進捗を示す
                        .frame(height: 10)
                        .padding(.top, 10)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 10) {
                    MovePyFeatView(title: "表情認識", description: "自分の表情から感情を読み取ってみる")
                    ProfileInfoView(title: "年齢", value: "30") // 年齢
                    ProfileInfoView(title: "都市", value: "New York") // 都市
                    ProfileInfoView(title: "趣味", value: "旅行、読書、料理") // 趣味
                    ProfileInfoView(title: "メアド", value: UserDefaults.standard.string(forKey: "user_email") ?? "”") // メールアドレス
                }
                .padding(.top, 20)
                
                Spacer()
                
                NavigationLink(destination: VoiceChat()) { // 通話画面に遷移するボタン
                    Image(systemName: "phone.fill") // 通話アイコン
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .padding(-15)
                        )
                        .padding()
                }
                .buttonStyle(PlainButtonStyle()) // ボタンスタイルの設定
            }
            .padding()
            .background(Color(red: 0.96, green: 0.98, blue: 0.92))
            //            .navigationBarTitle("プロフィール", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MovePyFeatView: View {
    var title: String
    var description: String
    
    var body: some View {
        NavigationLink(destination: PyFeatView()) {
            HStack {
                Image(systemName: "photo") // Using SF Symbols for an icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
                    .padding(.leading, 20)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileInfoView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(20)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(20)
        }
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 10)
                    
                    Rectangle()
                        .foregroundColor(Color.blue)
                        .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: 10)
                }
                .cornerRadius(5)
            }
            Text("30分")
                .foregroundColor(.gray)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
