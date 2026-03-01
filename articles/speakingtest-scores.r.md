---
title: "【R言語】印刷がラク！スピーキング評価のPDF一括生成ツール"
emoji: "🖨️"
type: "tech"
topics: ["r", "教育", "英語教育", "github", "データ分析"]
published: true
---

## はじめに

英語教育の現場において、パフォーマンス評価の実施後に最も頭を悩ませるのは「学生へのフィードバックをどうやって返すか」という問題です。

前回の記事では、Google Apps Script（GAS）を用いた手法を紹介しました。GASは「対面での即時共有」には非常に強力ですが、**数十人分のレポートを一括で印刷・配布したい場合**、Rを用いたPDF生成の方が圧倒的に効率的です。

今回は、Rを使って**生徒全員分のレポートを1つのPDFファイルにまとめる**ツールを公開します。

※本記事は、すでにPCにRおよびRStudioがインストールされていることを前提としています。

### 1. コードとサンプルデータ（GitHub）

スクリプトと、動作確認用のサンプルデータはGitHubに公開しています。

👉 **https://github.com/KaitoKOGAWA/zenn-content/edit/main/articles/speakingtest-scores.r.md**

### 2. 準備するデータ構造

以下のようなCSVファイル（UTF-8形式）を用意します。今回のスクリプトは、1列目が「名前」、数値列が「評価観点」、列名に「コメント」を含む列が「フィードバック」として読み込まれる設計です。

| 名前 | 語彙・文法 | 流暢さ | 発音 | 一言コメント |
| :--- | :--- | :--- | :--- | :--- |
| 青木 健太 | 4 | 3 | 5 | つまずかずに話せるよう、音読やシャドーイングを... |
| 阿部 舞 | 3 | 4 | 4 | 文法や単語の幅を広げる練習をすると... |
| 石井 拓海 | 5 | 5 | 4 | 全体的に高い水準です。より洗練された語彙を... |

よろしければ、以下のデモデータを用いて試してみてください。

👉 **https://github.com/KaitoKOGAWA/zenn-content/blob/main/articles/speaking_score_demodata.csv**


### 3. Rスクリプト

RStudioで以下のコードを実行し、ダイアログからCSVを選択してください。デスクトップに `speaking_score.pdf` が生成されます。

```r
# 1. 必要なパッケージのインストールと読み込み
if (!require("fmsb")) install.packages("fmsb")
if (!require("showtext")) install.packages("showtext")
library(fmsb)
library(showtext)

# 2. フォントの設定（Klee Oneを使用）
font_add_google("Klee One", "kyokasho")
showtext_auto()

# 3. データの読み込み
file_path <- file.choose()
data <- read.csv(file_path, fileEncoding = "UTF-8", check.names = FALSE)

# 4. 出力先（デスクトップ）のパス取得
get_desktop <- function() {
  tp <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
  tp_one <- file.path(Sys.getenv("USERPROFILE"), "OneDrive", "Desktop")
  tp_one_jp <- file.path(Sys.getenv("USERPROFILE"), "OneDrive", "デスクトップ")
  if (dir.exists(tp)) return(tp)
  if (dir.exists(tp_one)) return(tp_one)
  if (dir.exists(tp_one_jp)) return(tp_one_jp)
  return(getwd())
}

output_path <- file.path(get_desktop(), "speaking_score.pdf")

# 5. PDF出力開始
pdf(output_path, width = 7, height = 9)
layout(matrix(c(1, 2), nrow = 2), heights = c(1, 0.8))
par(family = "kyokasho")

# 6. スコア計算とループ処理
score_cols <- sapply(data, is.numeric)
scores_data <- data[, score_cols]
max_val <- rep(max(scores_data, na.rm = TRUE), ncol(scores_data))
min_val <- rep(0, ncol(scores_data))

for (i in 1:nrow(data)) {
  target_name <- data[i, 1]
  target_scores <- scores_data[i, ]
  comment_col <- grep("コメント", colnames(data))
  comment_text <- if(length(comment_col) > 0) as.character(data[i, comment_col[1]]) else ""

  # レーダーチャート
  par(mar = c(0, 3, 4, 3))
  radarchart(rbind(max_val, min_val, target_scores), axistype = 1,
             title = paste(target_name, "の評価レポート"),
             pcol = rgb(0.2, 0.6, 0.6, 0.9), pfcol = rgb(0.2, 0.6, 0.6, 0.4), plwd = 3)

  # テキスト
  plot.new()
  text(0.5, 0.95, "【 スコア一覧 】", cex = 1.1, font = 2)
  text(0.5, 0.85, paste(colnames(target_scores), target_scores, sep = ": ", collapse = "  "), cex = 1.0)
  text(0.5, 0.65, "【 フィードバック 】", cex = 1.1, font = 2)
  text(0.5, 0.55, paste(strwrap(comment_text, width = 40), collapse = "\n"), cex = 1.0, adj = c(0.5, 1))
}
dev.off()
```

### 4．このツールの利点
このツールの利点は、何より「印刷がしやすいこと」です。1人1枚のPDFやExcelシートを生成すると、印刷時にファイルを開いて印刷する作業を人数分繰り返すことになります。pdf()関数を開いた状態でループ処理を回すことで、「40人クラスなら40ページのPDFが1つできる」状態にし、一括印刷を可能にしています。

### 5．まとめ
このツールを通して、フィードバックの効率や先生方のコピペの負担が減り、より深いスピーキングテストの結果分析や教材研究の時間が増えますことを心から願っております。
