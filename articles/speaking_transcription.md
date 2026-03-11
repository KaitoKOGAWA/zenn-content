---
title: "【Python】音声を一括文字起こし！Whisper×Colabで1つのWordに集約する自動化スクリプト"
emoji: "🎙️"
type: "tech"
topics: ["python", "whisper", "教育", "英語教育", "データ分析"]
published: true
---

## はじめに

教育現場において、スピーキングテストやインタビューの文字起こしは避けて通れない「苦行」です。


しかし、生徒の発話内容には、使用している語彙やポーズの長さなど、今後の指導に生かせるヒントはたくさん隠れています。


前回の記事で、スピーキングテストのスコアごとの発話をコピペし、ボタンを押すだけで指導が必要な単語を識別してくれるシステムを紹介しました。


本記事はその続きで、肝心の「文字起こし」を簡単に行うツールを紹介します。具体的には、Pythonを使って**「大量の音声ファイルを一括で文字起こしし、最後に1つのWordファイルに集約してダウンロードする」**ツールとなっております。非エンジニアの方でも、コピペだけで明日から使える仕様にしています。

---

## なぜGoogle Colabなのか？

今回のツールは「Google Colaboratory（Colab）」上で動かします。理由は以下の通りです。

1. **環境構築が不要**: ブラウザがあれば誰でもすぐにPythonを実行できます。
2. **無料でGPUが使える**: AIによる音声認識（Whisper）は計算量が多いですが、Colabの無料GPUを使えば高速に処理できます。
3. **OSに依存しない**: WindowsでもMacでも、学校の端末でも同じように動作します。

## 技術スタック

* **OpenAI Whisper**: 高精度な多言語対応の文字起こしAIモデル。
* **python-docx**: PythonからWord（.docx）ファイルを生成・操作するためのライブラリ。

---

## 開発経緯とこだわりのポイント

単なる「文字起こしツール」ではなく、現場の泥臭い課題を解決するために3つの工夫を組み込みました。

### 1. ブラウザのダウンロード制限対策（1ファイル集約）
40人分の音声データを処理する際、1ファイルずつWordを生成してダウンロードしようとすると、ブラウザのセキュリティ制限に引っかかり処理が止まってしまう問題がありました。
**解決策:** すべての解析結果をメモリ上で1つのWordファイル（.docx）に追記していき、**最後に1回だけダウンロードする**設計にしました。

### 2. フィラー（言い淀み）の制御
SLA（第二言語習得）研究などでは、学習者の「えーっと」「あー」といった言い淀み（フィラー）も重要なデータです。しかし、Whisperはデフォルトでこれらをノイズと判定し、綺麗な文章に修正してしまいます。
**解決策:** `initial_prompt` 機能を利用し、AIに対して事前に「Umm, let me see...」などの例を与えることで、**フィラーを極力保持したまま文字起こし**を行うスイッチ（`KEEP_FILLERS`）を実装しました。

### 3. 後工程を邪魔しないクリーンなテキスト出力
エラー発生時にプログラム全体が止まらないよう例外処理（Try-Except）を入れています。また、文字起こし後のデータをChatGPT等の生成AIや、Rでのテキストマイニングに流し込みやすいよう、ファイル名などの余計な装飾を省いた**「純粋なテキストのみ」を抽出するクリーン出力**にこだわりました。

---

## 使い方：Google Colabの準備と実行手順

ここからは、実際にコードを動かす手順を説明します。5分もあれば準備は完了します。

### Step 1: Google Colabを開く
1. Googleアカウントにログインした状態で、[Google Colaboratory](https://colab.research.google.com/) にアクセスします。
2. ポップアップ画面が出るので、右下の**「ノートブックを新規作成」**をクリックします。
3. まっさらな画面が開き、中央に「▶」ボタンがついた入力欄（これを**セル**と呼びます）が表示されます。

### Step 2: コードを貼り付ける
以下のコードをすべてコピーし、先ほど開いたColab画面の**セル（`[ ]` の右側にある入力エリア）にそのまま貼り付けます。**

```python
# =================================================================
# 音声一括文字起こし & Word集約ツール
# =================================================================

import os

# 1. 必要なライブラリのインストール
print("【System】環境をセットアップしています...")
os.system('pip install -q git+[https://github.com/openai/whisper.git](https://github.com/openai/whisper.git)')
os.system('pip install -q ffprobe ffmpeg-python')
os.system('pip install -q python-docx')

import whisper
from google.colab import files
from docx import Document

# --- 設定項目 ---
# フィラー（Umm, uh等の言い淀み）を極力保持するかどうか
# True: 保持を試みる / False: AIが自動的に除去して綺麗な文章にする
KEEP_FILLERS = True
# 使用するAIモデル (tiny, base, small, medium, large)
MODEL_SIZE = "base"
# 出力ファイル名
OUTPUT_FILENAME = "transcription_results.docx"
# ----------------

def main():
    print(f"【System】モデル({MODEL_SIZE})をロード中...")
    model = whisper.load_model(MODEL_SIZE)

    print("【Action】解析したい音声ファイルを一括でアップロードしてください。")
    uploaded = files.upload()

    if not uploaded:
        print("【Error】ファイルが選択されませんでした。")
        return

    # Wordドキュメントの初期化
    doc = Document()

    # アップロードされたファイルをファイル名順にソートして処理
    sorted_filenames = sorted(uploaded.keys())

    print(f"\n合計 {len(sorted_filenames)} 個のファイルを処理します。")

    for i, filename in enumerate(sorted_filenames, 1):
        print(f"[{i}/{len(sorted_filenames)}] Processing: {filename}")
        
        try:
            # プロンプトの設定（フィラー保持用）
            initial_prompt = "Umm, let me see, uh, well, I mean..." if KEEP_FILLERS else ""
            
            # 文字起こしの実行
            result = model.transcribe(
                filename, 
                initial_prompt=initial_prompt
            )
            
            # 取得したテキストの整形
            transcribed_text = result["text"].strip()

            # Wordファイルへの書き込み（テキストと空行のみのシンプル構成）
            doc.add_paragraph(f"■ {filename}")
            doc.add_paragraph(transcribed_text)
            doc.add_paragraph("") # セクション間の空行

        except Exception as e:
            print(f"  [Error] {filename} の処理中にエラーが発生しました: {e}")
            # エラー時は空行を挿入してスキップ
            doc.add_paragraph(f"(Processing Error: {filename} / {e})")
            doc.add_paragraph("")

    # ファイルの保存とダウンロード
    doc.save(OUTPUT_FILENAME)
    print("\n--------------------------------------------------")
    print(f"【Success】すべての処理が完了しました。")
    files.download(OUTPUT_FILENAME)

if __name__ == "__main__":
    main()
```


💡 **手元に音声データがない方へ（デモデータのご案内）**
「まずはどんな動きをするか試してみたい」という方のために、テスト用の短い音声ファイル（デモデータ）を用意しました。
以下のGitHubリンクからダウンロードして、次の「Step 3」でアップロードしてみてください。


**https://github.com/KaitoKOGAWA/speaking_transcription_demodata/blob/main/Student_Audio_Files.zip**
にアクセスする。

画面右側にあるDownload raw file」アイコン（↓マーク）をクリックして、パソコンに保存する。

### Step 3: プログラムを実行する
**1**．セルの左側にある「▶（再生）」ボタンクリックします（または Shift + Enter を押します）。

**2**．初回は「このノートブックは Google が作成したものではありません。」という警告が出る場合がありますが、「そのまま実行」をクリックしてください。

**3**．プログラムが動き出し、必要なシステムの準備（インストール）が始まります。

**4**．しばらくすると「【Action】解析したい音声ファイルを一括でアップロードしてください。」という文字と共に、「ファイル選択」ボタンが現れます。

**5**．ボタンを押し、文字起こししたい音声ファイル（複数選択可）を選んでアップロードします。

**6**．あとは待つだけです。処理が完了すると、自動的に transcription_results.docx というWordファイルがパソコンにダウンロードされます。



## まとめ
いかがでしたか？文字起こしの手間がなくなると、**スピーキングテストの結果の考察やフィードバックの質が格段に上がり**、より「**生徒の学習**」と「**先生方の指導**」の向上に繋がることが期待できます。

本ツールで文字起こしした生徒の発話を、前回の私の記事で紹介したツールを用いて、「定着済み・未定着・発展途上」の単語を識別することができます。興味のある方はそちらもご覧いただいき、ぜひ使用していただけますと幸いです。

使ってみてのご感想、その他教育現場でのお悩み等ございましたら、ぜひコメントをお願いいたします。
