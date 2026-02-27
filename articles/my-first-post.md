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
# 保存する
    * 右上の緑色の **「Commit changes...」** を押し、再度 **「Commit changes」** を押します。

---

# 根拠
* **Front Matterのルール**: Zennでは冒頭の `---` で囲まれた部分に「タイトル」や「公開設定」を書くルールがあります。ここに余計な文章（私の行動提案など）が入ると、システムが混乱して記事を表示できません。
* **コードブロック**: ` ```r ` で囲むことで、Zenn上でコードが色付きで綺麗に表示されます。

---

# 行動の提案
この修正をして保存し直せば、今度こそ[Zennの「記事の管理」ページ](https://zenn.dev/dashboard/articles)に正しいタイトルで「下書き」が出現します。
