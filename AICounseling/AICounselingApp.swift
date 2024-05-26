//
//  AICounselingApp.swift
//  AICounseling
//
//  Created by 早乙女琉真 on 2024/05/11.
//

import SwiftUI

@main
struct AICounselingApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // ログイン済みの場合はTopViewに遷移
                TopView()
            } else {
                // ログインしていない場合はログイン画面を表示
                LoginView()
            }
        }
    }
}
