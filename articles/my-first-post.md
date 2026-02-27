---
title: "Rによる診断的言語テスト（DLA）の可視化：ggplot2を用いたフィードバックの自動化"
emoji: "📊"
type: "tech"
topics: ["R", "SLA", "教育", "統計"]
published: false
---

# はじめに
診断的言語テスト（DLA）において、学習者へのフィードバックは迅速かつ正確である必要があります。本記事では、Rの`ggplot2`を用いて、テスト結果を美しく可視化する手法を紹介します。

# 環境準備
まずは必要なパッケージを読み込みます。
```r
library(tidyverse)
df <- data.frame(
  Skill = c("Grammar", "Vocabulary", "Reading", "Listening"),
  Score = c(85, 70, 90, 65)
)
ggplot(df, aes(x = Skill, y = Score, fill = Skill)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Diagnostic Test Profile")
---

**【行動の提案】**
保存が完了したら、[Zennの「記事の管理」ページ](https://zenn.dev/dashboard/articles)を開いてみてください。

数秒後に、あなたの名前で**「下書き」**として記事が表示されます。表示されたら教えてください。そこから先の「自分のPCにRを入れる方法」や「記事の公開」についても丁寧に伴走します！
