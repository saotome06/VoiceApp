import SwiftUI

struct OthelloView: View {
    @StateObject private var gameModel = OthelloGameModel()
    @State var aiComment: String = ""
    
    var body: some View {
        VStack {
            Text("オセロゲーム")
                .font(.largeTitle)
            
            BoardView(gameModel: gameModel)
            
            Text("現在のターン: \(gameModel.currentPlayer == .black ? "黒" : "白")")
            
            Text("AIのコメント: \(aiComment)")
                .padding()
            
            Button("パス") {
                gameModel.pass()
            }
            .disabled(gameModel.hasValidMoves())
            
            Button("リセット") {
                gameModel.resetGame()
                aiComment = ""
            }
        }
        .onChange(of: gameModel.currentPlayer) { newPlayer in
            if newPlayer == .white {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameModel.makeAIMove()
                }
            }
        }
    }
}

struct BoardView: View {
    @ObservedObject var gameModel: OthelloGameModel
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<8, id: \.self) { column in
                        CellView(cell: gameModel.board[row][column])
                            .onTapGesture {
                                gameModel.makeMove(row: row, column: column)
                            }
                    }
                }
            }
        }
        .background(Color.green)
        .padding()
    }
}

struct CellView: View {
    let cell: OthelloGameModel.CellState
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
            
            if cell != .empty {
                Circle()
                    .fill(cell == .black ? Color.black : Color.white)
                    .frame(width: 35, height: 35)
            }
        }
    }
}

class OthelloGameModel: ObservableObject {
    enum CellState {
        case empty, black, white
    }
    
    enum Player {
        case black, white
    }
    
    @Published var board: [[CellState]]
    @Published var currentPlayer: Player
    @ObservedObject private var viewModel = CreateAudioViewModel2()
    @ObservedObject private var interjectionModel = InterjectionVoice()
    
    init() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        currentPlayer = .black
        resetGame()
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        board[3][3] = .white
        board[3][4] = .black
        board[4][3] = .black
        board[4][4] = .white
        currentPlayer = .black
    }
    
    private let chatGPTService = ChatGPTService(systemContent: 
    """
    友達のように、一回の応答ではできる限り20文字以内で回答するようにして。
    
    女子高生になりきって。
    あなたはuserとオセロゲームをしています。対戦相手になりきってリアクションをしてください。
    オセロのコマの初期配置は以下の例のように表現されます。
    ........
    ........
    ........
    ...WB...
    ...BW...
    ........
    ........
    ........
    あなたのコマはWです。
    「プレイヤーが(6, 5)にBのコマを打ちました。」と言われたら、下記のような配置になります。
    ........
    ........
    ........
    ...WB...
    ...BB...
    ....B...
    ........
    ........
    """
    )
    
    func makeMove(row: Int, column: Int) {
        guard isValidMove(row: row, column: column) else { return }
        
        board[row][column] = currentPlayer == .black ? .black : .white
        flipPieces(row: row, column: column)
        // プレイヤーの手に対してAIのコメントを取得
        getAIComment(for: row, column: column)
        switchPlayer()
    }
    
    private func getAIComment(for row: Int, column: Int) {
        var boardState = getBoardStateString()
//        boardState =
//        """
//        ..BBBB..
//        ..BBBBWW
//        ..BBBB..
//        ..BBBB..
//        ..BBBB..
//        ..BBBBB.
//        ...W...B
//        ........
//        """
        print(boardState)
        let prompt =
        """
        現在の盤面は以下の通りです：\n\(boardState)\nこの手についてリアクションをしてください。
        """
        if currentPlayer == .black {
            chatGPTService.fetchResponse(prompt) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let comment):
                        print(comment)
                        Task {
                            async let interjectionAudio = self.interjectionModel.playRandomAssetAudio(voiceId: "8EkOjt4xTPGMclNlh1pk")
                            async let createSpeech = try await self.viewModel.createSpeech(input: comment, voice: "8EkOjt4xTPGMclNlh1pk")
                            // 両方の処理が完了するのを待つ
                            _ = await (interjectionAudio, createSpeech)
                        }
                        self.objectWillChange.send()
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.contentView.aiComment = comment
                    case .failure(let error):
                        print("Error getting AI comment: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func getBoardStateString() -> String {
        var stateString = ""
        for row in board {
            for cell in row {
                switch cell {
                case .empty: stateString += "."
                case .black: stateString += "B"
                case .white: stateString += "W"
                }
            }
            stateString += "\n"
        }
        return stateString
    }
    
    func makeAIMove() {
        guard currentPlayer == .white else { return }
        
        var bestScore = Int.min
        var bestMove: (Int, Int)?
        
        for row in 0..<8 {
            for column in 0..<8 {
                if isValidMove(row: row, column: column) {
                    let score = evaluateMove(row: row, column: column)
                    if score > bestScore {
                        bestScore = score
                        bestMove = (row, column)
                    }
                }
            }
        }
        
        if let move = bestMove {
            makeMove(row: move.0, column: move.1)
        } else {
            pass()
        }
    }
    
    func pass() {
        switchPlayer()
    }
    
    private func switchPlayer() {
        currentPlayer = currentPlayer == .black ? .white : .black
        
        if !hasValidMoves() {
            currentPlayer = currentPlayer == .black ? .white : .black
            if !hasValidMoves() {
                print("ゲーム終了")
            }
        }
    }
    
    func hasValidMoves() -> Bool {
        for row in 0..<8 {
            for column in 0..<8 {
                if isValidMove(row: row, column: column) {
                    return true
                }
            }
        }
        return false
    }
    
    private func isValidMove(row: Int, column: Int) -> Bool {
        guard board[row][column] == .empty else { return false }
        
        let directions = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]
        let currentColor = currentPlayer == .black ? CellState.black : CellState.white
        let oppositeColor = currentPlayer == .black ? CellState.white : CellState.black
        
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            var foundOpposite = false
            
            while x >= 0 && x < 8 && y >= 0 && y < 8 {
                if board[x][y] == oppositeColor {
                    foundOpposite = true
                } else if board[x][y] == currentColor && foundOpposite {
                    return true
                } else {
                    break
                }
                
                x += dx
                y += dy
            }
        }
        
        return false
    }
    
    private func flipPieces(row: Int, column: Int) {
        let directions = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]
        let currentColor = currentPlayer == .black ? CellState.black : CellState.white
        let oppositeColor = currentPlayer == .black ? CellState.white : CellState.black
        
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            var toFlip: [(Int, Int)] = []
            
            while x >= 0 && x < 8 && y >= 0 && y < 8 {
                if board[x][y] == oppositeColor {
                    toFlip.append((x, y))
                } else if board[x][y] == currentColor {
                    for (flipX, flipY) in toFlip {
                        board[flipX][flipY] = currentColor
                    }
                    break
                } else {
                    break
                }
                
                x += dx
                y += dy
            }
        }
    }
    
    private func evaluateMove(row: Int, column: Int) -> Int {
        var tempBoard = board
        let currentColor = currentPlayer == .black ? CellState.black : CellState.white
        tempBoard[row][column] = currentColor
        
        var score = 0
        
        // 1. 角の確保
        let corners = [(0,0), (0,7), (7,0), (7,7)]
        for (r, c) in corners {
            if tempBoard[r][c] == currentColor {
                score += 100
            }
        }
        
        // 2. 辺の石の数
        for i in 0..<8 {
            if tempBoard[0][i] == currentColor { score += 5 }
            if tempBoard[7][i] == currentColor { score += 5 }
            if tempBoard[i][0] == currentColor { score += 5 }
            if tempBoard[i][7] == currentColor { score += 5 }
        }
        
        // 3. 石の総数
        for r in 0..<8 {
            for c in 0..<8 {
                if tempBoard[r][c] == currentColor {
                    score += 1
                }
            }
        }
        
        // 4. 移動可能手数
        let opponentPlayer = currentPlayer == .black ? Player.white : Player.black
        let opponentMoves = countValidMoves(for: opponentPlayer, on: tempBoard)
        score -= opponentMoves * 2
        
        return score
    }
    
    private func countValidMoves(for player: Player, on board: [[CellState]]) -> Int {
        var count = 0
        for row in 0..<8 {
            for column in 0..<8 {
                if isValidMove(row: row, column: column, for: player, on: board) {
                    count += 1
                }
            }
        }
        return count
    }
    
    private func isValidMove(row: Int, column: Int, for player: Player, on board: [[CellState]]) -> Bool {
        guard board[row][column] == .empty else { return false }
        
        let directions = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]
        let currentColor = player == .black ? CellState.black : CellState.white
        let oppositeColor = player == .black ? CellState.white : CellState.black
        
        for (dx, dy) in directions {
            var x = row + dx
            var y = column + dy
            var foundOpposite = false
            
            while x >= 0 && x < 8 && y >= 0 && y < 8 {
                if board[x][y] == oppositeColor {
                    foundOpposite = true
                } else if board[x][y] == currentColor && foundOpposite {
                    return true
                } else {
                    break
                }
                
                x += dx
                y += dy
            }
        }
        
        return false
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var contentView = OthelloView()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

struct OthelloView_Previews: PreviewProvider {
    static var previews: some View {
        OthelloView()
    }
}
