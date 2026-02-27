title: "Rによる診断的言語テスト（DLA）の可視化：ggplot2を用いたフィードバックの自動化" emoji: "📊" type: "tech" topics: ["R", "SLA", "教育", "統計"] published: false
はじめに
診断的言語テスト（DLA）において、学習者へのフィードバックは迅速かつ正確である必要があります。本記事では、Rのggplot2を用いて、テスト結果を美しく可視化する手法を紹介します。

環境準備
まずは必要なパッケージを読み込みます。

R
library(tidyverse)
ダミーデータの作成
分析用のサンプルデータを作成します。

R
df <- data.frame(
  Skill = c("Grammar", "Vocabulary", "Reading", "Listening"),
  Score = c(85, 70, 90, 65)
)
可視化の実践
ggplot2を使用して棒グラフを作成します。

R
ggplot(df, aes(x = Skill, y = Score, fill = Skill)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Diagnostic Test Profile")
おわりに
このように、Rを活用することで評価業務の効率化が可能です。
