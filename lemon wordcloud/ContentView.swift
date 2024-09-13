import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var words: [Word] = [] // 単語リスト
    @State private var selectedTags: Set<String> = [] // 選択されたタグ（複数選択対応）
    @State private var showingFilterActionSheet = false // 絞り込みアクションシートの表示フラグ
    
    var body: some View {
        NavigationView {
            VStack {
                // タグ選択のUIを追加
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(getAllTags(), id: \.self) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                Text(tag)
                                    .padding(8)
                                    .background(selectedTags.contains(tag) ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                
                List {
                    ForEach(filteredWords()) { word in
                        NavigationLink(destination: WordDetailView(word: word)) {
                            HStack {
                                if let image = word.image {
                                    image
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }
                                Text(word.title)
                            }
                        }
                    }
                    .onDelete(perform: deleteWord)
                }
            }
            .navigationTitle("Word List")
            .toolbar {
                // 右上にプラスボタンとアクションボタンを追加
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: AddWordView(words: $words)) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
    
    // 単語をリストから削除するメソッド
    func deleteWord(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }
    
    // タグに基づいて単語をフィルタリングするメソッド
    func filteredWords() -> [Word] {
        if selectedTags.isEmpty {
            return words
        } else {
            return words.filter { !Set($0.tags).isDisjoint(with: selectedTags) }
        }
    }
    
    // 全てのタグを取得するメソッド
    func getAllTags() -> [String] {
        let allTags = words.flatMap { $0.tags }
        return Array(Set(allTags)) // 重複を削除してユニークなタグを返す
    }
}

// 単語データモデル
struct Word: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let image: Image? // 画像がある場合は表示する
    let audioUrl: String // 音声ファイルのURL
    let url: String
    let tags: [String]
    let date: Date
}

// 単語詳細ページ
struct WordDetailView: View {
    var word: Word
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let image = word.image {
                    image
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
                
                Text("タイトル: \(word.title)")
                    .font(.largeTitle)
                    .padding()
                
                Text("詳細: \(word.detail)")
                    .font(.body)
                    .padding()
                
                if !word.tags.isEmpty {
                    Text("タグ: " + word.tags.joined(separator: ", "))
                        .padding()
                }
                
                // 音声再生ボタン
                if !word.audioUrl.isEmpty {
                    Button(action: {
                        playAudio(urlString: word.audioUrl)
                    }) {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("音声を再生")
                        }
                    }
                    .padding()
                }
                
                if !word.url.isEmpty {
                    Text("関連URL: \(word.url)")
                        .padding()
                }
                
                Text("日付: \(word.date.formatted())")
                    .padding()
                
                Spacer()
            }
            .navigationTitle("単語の詳細")
        }
    }
    
    // 音声を再生するメソッド
    func playAudio(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("音声ファイルの再生に失敗しました: \(error)")
        }
    }
}

// プレビュー用のコード
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
