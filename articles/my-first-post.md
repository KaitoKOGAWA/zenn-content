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
**# ダミーデータの作成**
分析用のサンプルデータを作成します。

R
df <- data.frame(
  Skill = c("Grammar", "Vocabulary", "Reading", "Listening"),
  Score = c(85, 70, 90, 65)
)
可視化の実践
