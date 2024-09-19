//
//  WordItem.swift
//  lemon wordcloud
//
//  Created by いしづかれい on 2024/09/16.
//

import Foundation
import SwiftUI



struct WordItem: Identifiable{
    let id = UUID()
    let title: String
    let detail: String
    let image: Image? // 画像がある場合は表示する
    let audioUrl: String // 音声ファイルのURL
    let url: String
    let tags: [String]
    let date: Date
}
