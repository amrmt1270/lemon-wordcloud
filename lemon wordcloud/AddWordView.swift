import SwiftUI
import AVFoundation

struct AddWordView: View {
    @Binding var words: [Word] // 親ビューから単語リストを参照
    
    @Environment(\.presentationMode) var presentationMode // 戻るための環境変数
    
    @State private var wordTitle: String = "" // 単語名
    @State private var wordDetail: String = "" // 単語の詳細
    @State private var image: Image? = nil // SwiftUI用の画像
    @State private var inputImage: UIImage? = nil // UIImage用の画像
    @State private var showingImagePicker = false // 画像ピッカー表示フラグ
    @State private var url: String = "" // URL
    @State private var selectedDate = Date() // 日付
    
    // タグ関連
    @State private var tags: [String] = [] // タグのリスト
    @State private var newTag: String = "" // 新しいタグの入力
    
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false // 録音状態の管理
    @State private var recordedAudioURL: URL? // 録音した音声の保存URL
    
    var body: some View {
        NavigationView {
            Form {
                // 単語名入力
                Section(header: Text("単語名")) {
                    TextField("単語名を入力してください", text: $wordTitle)
                        .keyboardType(.default) // 日本語入力用のキーボード
                }
                
                // タグの入力（単語名の下）
                Section(header: Text("タグ")) {
                    HStack {
                        TextField("タグを追加", text: $newTag)
                        Button(action: {
                            addTag()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    // 追加されたタグのリスト表示
                    if !tags.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                
                // 単語の詳細入力（大きな入力領域）
                Section(header: Text("単語の詳細")) {
                    TextEditor(text: $wordDetail)
                        .frame(height: 150) // 高さを指定して大きな入力領域に
                }
                
                // 画像の選択
                Section(header: Text("画像")) {
                    Button(action: {
                        showingImagePicker = true // 画像選択を表示
                    }) {
                        Text("画像を選択")
                    }
                    
                    // 画像を表示
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
                
                // 音声の録音（任意）
                Section(header: Text("音声録音")) {
                    HStack {
                        Button(action: {
                            if isRecording {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        }) {
                            Image(systemName: isRecording ? "stop.circle" : "mic.circle")
                                .font(.largeTitle)
                        }
                        Text(isRecording ? "録音中..." : "録音を開始")
                    }
                    
                    // 録音した音声ファイルのURLを表示
                    if let recordedAudioURL = recordedAudioURL {
                        Text("録音が保存されました: \(recordedAudioURL.lastPathComponent)")
                    }
                }
                
                // URLの入力
                Section(header: Text("関連URL")) {
                    TextField("URLを入力してください", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                // 日付選択
                Section(header: Text("日付")) {
                    DatePicker("日付を選択してください", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("新しい単語を追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("保存") {
                saveWord()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage) // 画像ピッカーを表示
            }
            .onChange(of: inputImage) { _ in loadImage() }
        }
    }
    
    // タグを追加する関数
    func addTag() {
        if !newTag.isEmpty {
            tags.append(newTag)
            newTag = "" // 追加後にテキストフィールドをクリア
        }
    }
    
    // 録音を開始する関数
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordedAudioURL = audioFilename
        } catch {
            stopRecording()
        }
    }
    
    // 録音を停止する関数
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    // ドキュメントディレクトリを取得する関数
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // 画像を読み込み、SwiftUIのImageに変換
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    // 単語を保存する関数
    func saveWord() {
        let newWord = Word(title: wordTitle, detail: wordDetail, image: image, audioUrl: recordedAudioURL?.absoluteString ?? "", url: url, tags: tags, date: selectedDate)
        words.append(newWord)
        presentationMode.wrappedValue.dismiss()
    }
}
