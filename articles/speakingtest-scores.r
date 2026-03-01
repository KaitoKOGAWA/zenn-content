---
title: "【R言語】印刷がラク！スピーキングテスト結果のPDF一括生成ツール"
emoji: "🖨️"
type: "tech"
topics: ["r", "教育", "英語教育", "github", "データ分析"]
published: false
---

# はじめに
英語教育の現場において、スピーキングテストの実施後に最も頭を悩ませるのは「学生へのフィードバックをどうやって返すか」という問題です。

前回の記事では、Google Apps Script（GAS）を用いたフィードバック手法を紹介しました。GASは「対面でのフィードバック」や「Web画面での即時共有」において非常に強力です。
一方で、**成績表と一緒に紙面で配布したい場合や、学期末の記録として一括印刷したい場合**、GASのシステムでは印刷の手間がかかってしまいます。

そこで今回は、データ分析言語「R」を用いて、**学生全員分のレーダーチャート付き評価レポートを、1つのPDFファイルとして一括生成する**手法を共有します。これにより、結果の印刷・配布にかかる手間を極限まで省くことができます。



※本記事は、すでにPCにRおよびRStudioがインストールされていることを前提としています。

## 1. 準備するデータ（CSV）

以下のような形式で、生徒の氏名と実際のスコア、それに対するコメントをまとめたCSVファイル（UTF-8）を準備します。1列目に名前、中間にスコア（数値）、最後に「一言コメント」という文字列を含む列名を用意してください。

よろしければ、以下に添付したデモのcsvデータで試してみてください。
speaking_score_demodata.csv



## 2. Rスクリプトの実行

RStudioを開き、以下のコードを実行します。
初心者の方がつまづきやすい「日本語の文字化け（豆腐化）」や「Windows環境でのデスクトップパスの迷子」を防ぐための処理を組み込んでいます。

```r
# 1. 必要なパッケージのインストールと読み込み
if (!require("fmsb")) install.packages("fmsb")
if (!require("showtext")) install.packages("showtext")
library(fmsb)      # レーダーチャート作成用
library(showtext)  # 日本語フォントの文字化け防止用

# 2. フォントの設定（Google Fontsを利用した文字化け対策）
# R標準のPDF出力による日本語文字化けを防ぐため、showtextを使用します。
# ここでは視認性が高く温かみのある「Klee One（教科書体風）」を指定しています。
font_add_google("Klee One", "kyokasho")
showtext_auto()

# 3. データの読み込み
# 実行時にダイアログが開き、対象のCSVファイルを選択できます。
file_path <- file.choose()
data <- read.csv(file_path, fileEncoding = "UTF-8", check.names = FALSE)

# 4. 出力先（デスクトップ）のパス取得関数
# Windows環境特有のOneDriveによるデスクトップパスの変更にも対応しています。
get_desktop <- function() {
  tp <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
  tp_one <- file.path(Sys.getenv("USERPROFILE"), "OneDrive", "Desktop")
  tp_one_jp <- file.path(Sys.getenv("USERPROFILE"), "OneDrive", "デスクトップ")
  if (dir.exists(tp)) return(tp)
  if (dir.exists(tp_one)) return(tp_one)
  if (dir.exists(tp_one_jp)) return(tp_one_jp)
  return(getwd())
}

# 出力ファイル名の設定（任意のファイル名に変更可能です）
desktop_path <- get_desktop()
file_name <- "speaking_score.pdf"
output_path <- file.path(desktop_path, file_name)

# 5. PDFデバイスの起動とレイアウト設定
pdf(output_path, width = 7, height = 9)

# 画面を上下に分割（チャート部分を1、テキスト部分を0.8の比率で配置）
layout(matrix(c(1, 2), nrow = 2), heights = c(1, 0.8))

# グラフ全体のフォントを適用
par(family = "kyokasho")

# 6. スコアの最大値・最小値の自動計算
# データフレームから数値列のみを抽出し、動的に目盛りを設定します。
score_cols <- sapply(data, is.numeric)
scores_data <- data[, score_cols]
global_max <- max(scores_data, na.rm = TRUE)
global_min <- 0
max_val <- rep(global_max, ncol(scores_data))
min_val <- rep(global_min, ncol(scores_data))

# 7. 全データのループ処理（1行＝1人分のページを生成）
for (i in 1:nrow(data)) {
  
  # データの抽出（1列目を名前、特定の列をコメントとして取得）
  target_name <- data[i, 1] 
  target_scores <- scores_data[i, ]
  comment_col <- grep("コメント", colnames(data))
  comment_text <- if(length(comment_col) > 0) as.character(data[i, comment_col[1]]) else ""

  # ① レーダーチャートの描画
  par(mar = c(0, 3, 4, 3)) 
  radar_data <- rbind(max_val, min_val, target_scores)
  
  radarchart(
    radar_data,
    axistype = 1,
    seg = global_max,
    caxislabels = 0:global_max,
    axislabcol = "grey",
    pcol = rgb(0.2, 0.6, 0.6, 0.9), 
    pfcol = rgb(0.2, 0.6, 0.6, 0.4),
    plwd = 3, 
    cglcol = "lightgrey", 
    cglty = 1, 
    vlcex = 1.1,
    title = paste(target_name, "の評価レポート")
  )
  
  # ② スコアとコメントの描画
  par(mar = c(0, 2, 0, 2)) 
  plot.new()
  
  # スコアを文字列として結合
  score_line <- paste(colnames(target_scores), target_scores, sep = ": ", collapse = "   ")
  
  text(0.5, 0.95, "【 スコア一覧 】", cex = 1.1, font = 2)
  text(0.5, 0.85, score_line, cex = 1.0)
  
  text(0.5, 0.65, "【 フィードバック 】", cex = 1.1, font = 2)
  
  # コメントが長い場合は自動で改行（widthで文字数を調整可能）
  wrapped_comment <- paste(strwrap(comment_text, width = 40), collapse = "\n")
  text(0.5, 0.55, wrapped_comment, cex = 1.0, adj = c(0.5, 1))
}

# 8. PDF出力の終了
dev.off()

cat("処理が完了しました。出力先ディレクトリ:", output_path, "\n")
