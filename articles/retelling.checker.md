# 【SLA×データ分析】英語教員向け：スピーキングテストの発話をとおして、単語の定着度を「上位・中位・下位」で可視化するブラウザツール

## 結論：この記事で得られること
スピーキングテストにおいて、「どの単語が、どの学力層の生徒に定着しているか」を瞬時に可視化する分析ツールを開発・公開しました。
本記事では、プログラミング知識ゼロの方でも、すぐに現場で使える本ツールの利用手順を丁寧に解説します。

## 1. なぜ「学力層別」の分析が必要なのか？（SLAの視点）

現場のスピーキング評価において、「クラス全体の平均点」だけを見ていても、指導改善に向けた具体的な示唆は得られません。特に、学習者が授業で導入された語彙を、単なる理解にとどまらず「発信語彙（Productive Vocabulary）」として内面化できているかは、多くの先生方が直面する課題であると感じます。

現行の学習指導要領では、小・中・高で習得するべき単語数が増加しました。しかし、それはあくまで受容語彙の話で、それらを全て発信語彙として運用できるようにならないわけではありません。また、日常生活や一般的なコミュニケーションの大部分は、高頻度語によってカバーされます。共通テストや英検などの外部試験においても、テキストに出てくる単語の大部分を高頻度語を説明できることがわかっており、低頻度語（学術論文などに出てくる、いわばニッチな単語）を習得する恩恵は限定的と言わざるを得ません。

そこで私は、先生方の「この単元ではこの単語を発信語彙として使えるようになってほしい」という思いを比較的容易に叶えるツールがあると面白いなと感じ、本ツールを開発しました。

## 2. 本ツールの3つの特徴

現場の先生方が安全かつ直感的に使えるよう、以下の仕様で設計しました。

1. **オフライン動作で個人情報を保護**
   ブラウザ上で全ての処理が完結するため、生徒の解答データが外部サーバーに送信されることは一切ありません。
2. **指導の「次の一手」を自動判定**
   目標語彙の定着度を算出し、「✅定着済（全体75%以上）」「⚠️格差あり（上位と下位で40%以上の差）」「❌未定着（全体30%未満）」の3パターンで自動分類します。

## 3. ツールの使い方

利用方法は2パターンあります。ご自身の環境に合わせてお選びください。

### 方法A：Web上でそのまま使う（推奨）
私が管理するGitHub Pagesにてツールを公開しています。以下のリンクをクリックするだけで、スマートフォンやPCのブラウザからすぐにご利用いただけます。
* **https://github.com/KaitoKOGAWA/zenn-content/edit/main/articles/retelling.checker.md**

### 方法B：コードをコピペして手元（オフライン）で使う
学校のネットワーク制限等でWeb版にアクセスできない場合は、以下の手順でご自身のPCに保存して使用できます。

1. 以下のコード右上の「コピー」ボタンを押します。
2. PCの「メモ帳」などを開き、ペーストします。
3. ファイル名を `Retelling_Checker.html` として保存します。
   ⚠️デフォルトだと.txtファイルで保存されてしまうため、かならず.htmlファイルに保存する際に書き換えてください。
5. 保存したファイルをダブルクリックしてブラウザで開きます。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>3グループ・分析ツール（カラー改良版）</title>
    <style>
        /* 全体の背景色とフォント設定 */
        body { font-family: sans-serif; background: #f0f2f5; padding: 20px; font-size: 14px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h1 { color: #1a73e8; border-bottom: 3px solid #1a73e8; padding-bottom: 10px; margin-bottom: 25px; }
        
        /* 入力エリアの設定 */
        .input-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        textarea { width: 100%; height: 120px; padding: 12px; border: 1px solid #bdc3c7; border-radius: 8px; box-sizing: border-box; font-size: 14px; }
        #classText { height: 250px; }
        button { width: 100%; padding: 18px; background: #1a73e8; color: white; border: none; font-size: 1.2rem; font-weight: bold; border-radius: 8px; cursor: pointer; transition: 0.2s; }
        button:hover { background: #1557b0; }
        
        /* 上部サマリーカードの配色設定 */
        .group-summary { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 10px; margin: 20px 0; }
        .group-card { padding: 15px; border-radius: 8px; text-align: center; font-weight: bold; border-bottom: 4px solid rgba(0,0,0,0.1); }
        .card-all  { background: #e8f0fe; color: #1a73e8; }
        .card-high { background: #fff9c4; color: #856404; } /* ゴールド */
        .card-mid  { background: #f5f5f5; color: #616161; } /* シルバー */
        .card-low  { background: #efebe9; color: #5d4037; } /* ブロンズ */
        .group-name { font-size: 0.85em; display: block; margin-bottom: 5px; opacity: 0.8; }
        .group-num { font-size: 1.4em; }

        /* テーブルのデザイン設定 */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #eee; padding: 12px; text-align: center; }
        
        /* 表の見出し配色（カードと連動） */
        .th-overall { background: #e8f0fe !important; }
        .th-high { background: #fff9c4 !important; color: #856404; }
        .th-mid  { background: #f5f5f5 !important; color: #616161; }
        .th-low  { background: #efebe9 !important; color: #5d4037; }
        
        .word-cell { text-align: left; font-weight: bold; color: #2c3e50; }
        
        /* 判定ラベルの配色 */
        .sign-good { color: #2ecc71; font-weight: bold; }
        .sign-gap  { color: #d4a017; font-weight: bold; background: #fffde7; }
        .sign-bad  { color: #e74c3c; font-weight: bold; }
    </style>
</head>
<body>

<div class="container">
    <h1>📊 上中下3グループ・定着度分析</h1>
    
    <div class="input-grid">
        <div>
            <label><strong>【理想の要約】</strong></label>
            <textarea id="idealText" placeholder="先生が求めるキーワードを含む英文を入力..."></textarea>
        </div>
        <div>
            <label><strong>【スコア付き生徒データ】</strong></label>
            <textarea id="classText" placeholder="4, Speech... (スコアと本文をカンマで区切って入力)"></textarea>
        </div>
    </div>

    <button onclick="threeGroupAnalysis()">分析を実行</button>

    <div id="resultArea" style="display:none;">
        <div class="group-summary">
            <div class="group-card card-all"><span class="group-name">全体</span><span id="numTotal" class="group-num">-</span></div>
            <div class="group-card card-high"><span class="group-name">上位層 (High)</span><span id="numHigh" class="group-num">-</span></div>
            <div class="group-card card-mid"><span class="group-name">中位層 (Middle)</span><span id="numMid" class="group-num">-</span></div>
            <div class="group-card card-low"><span class="group-name">下位層 (Low)</span><span id="numLow" class="group-num">-</span></div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>判定</th>
                    <th>重要単語</th>
                    <th class="th-overall">全体</th>
                    <th class="th-high">上位層</th>
                    <th class="th-mid">中位層</th>
                    <th class="th-low">下位層</th>
                    <th>指導アドバイス</th>
                </tr>
            </thead>
            <tbody id="resultBody"></tbody>
        </table>
    </div>
</div>

<script>
function threeGroupAnalysis() {
    const idealInput = document.getElementById('idealText').value.trim();
    const classInput = document.getElementById('classText').value.trim();
    if(!idealInput || !classInput) return alert("入力してください");

    const targetWords = [...new Set(tokenize(idealInput))].filter(w => w.length >= 4);
    const studentEntries = classInput.split(/\n\s*\n/).filter(t => t.trim().length > 0);
    
    const students = studentEntries.map(entry => {
        const firstComma = entry.indexOf(',');
        const score = parseInt(entry.substring(0, firstComma)) || 0;
        const speech = entry.substring(firstComma + 1);
        return { words: tokenize(speech), score: score };
    });

    // スコア順にソート
    students.sort((a, b) => b.score - a.score);
    
    // 安定版の人数分割ロジック
    const total = students.length;
    const third = Math.floor(total / 3);
    const remainder = total % 3;

    // 余りを中位層に寄せるように調整（安定版ロジック）
    let highEnd = third;
    let midEnd = highEnd + third + remainder;

    const highGroup = students.slice(0, highEnd);
    const midGroup = students.slice(highEnd, midEnd);
    const lowGroup = students.slice(midEnd);

    if (highGroup.length === 0 || lowGroup.length === 0) {
        alert("生徒数が少なすぎるため、正常にグループ分けできません。3名以上で入力してください。");
        return;
    }

    let html = "";
    targetWords.forEach(word => {
        const calc = (grp) => grp.length === 0 ? 0 : Math.round((grp.filter(s => s.words.includes(word)).length / grp.length) * 100);
        
        const rTotal = Math.round((students.filter(s => s.words.includes(word)).length / total) * 100);
        const rHigh = calc(highGroup);
        const rMid = calc(midGroup);
        const rLow = calc(lowGroup);

        let sign = "-";
        let adv = "定着の途上";
        let cellCls = "";

        if (rTotal >= 75) {
            sign = "✅定着済"; adv = "全員が習得"; cellCls = "sign-good";
        } else if (rHigh - rLow >= 40) {
            sign = "⚠️格差あり"; adv = "上位のみ使用"; cellCls = "sign-gap";
        } else if (rTotal < 30) {
            sign = "❌未定着"; adv = "全体に再指導"; cellCls = "sign-bad";
        }

        html += `<tr class="${cellCls === 'sign-gap' ? 'sign-gap' : ''}">
            <td class="${cellCls}">${sign}</td>
            <td class="word-cell">${word}</td>
            <td class="th-overall">${rTotal}%</td>
            <td class="th-high">${rHigh}%</td>
            <td class="th-mid">${rMid}%</td>
            <td class="th-low">${rLow}%</td>
            <td>${adv}</td>
        </tr>`;
    });

    document.getElementById('numTotal').innerText = total + "名";
    document.getElementById('numHigh').innerText = highGroup.length + "名";
    document.getElementById('numMid').innerText = midGroup.length + "名";
    document.getElementById('numLow').innerText = lowGroup.length + "名";
    document.getElementById('resultBody').innerHTML = html;
    document.getElementById('resultArea').style.display = 'block';
}

function tokenize(text) {
    return text.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/).filter(w => w.length > 0);
}
</script>
```
#### データの入力
ツールが開いたら、以下の2箇所に入力します。

【理想の要約】

生徒に必ず使ってほしいキーワードを含む、模範となる英文を入力します。

例: The main character visited a small village to find the secret treasure.

【スコア付き生徒データ】

生徒ごとの「ルーブリック等でつけたスコア」と「実際のリテリング用テキスト」をカンマ（,）で区切って入力します。改行して複数人分を入力してください。

例:
4, The character went to a village and found a treasure.
2, He visited a small town.

#### 💡 すぐに試せる！練習用サンプルデータ
ご自身の手元にデータがない場合は、以下のサンプルデータ（約40名分の1クラスを想定）をコピーして、ツールの動作を体験してみてください。

**①【評価ターゲット語彙・フレーズ（カンマ区切り）】に入力するテキスト**
以下の英文をコピーして貼り付けてください。
```text
Environmental issues, serious, waste, dangerous, sea animals, reduce, generation
```
**②【スコア付き生徒データ】に入力するテキスト**
以下のデータをすべてコピーして貼り付けてください（ルーブリック評価4〜1点のダミーデータです）。
```text
4, Environmental issues are serious. Plastic waste flows into the ocean. It is dangerous for sea animals. We must reduce plastic bags and bottles to protect the environment for the next generation.
4, Today, environmental issues are serious. Plastic flows into the ocean. Dangerous for sea animals. We should reduce bags for the next generation.
4, Plastic waste is a serious environmental problem. It flows into the ocean. It is dangerous. We must reduce plastic bottles for the next generation.
4, Environmental issues are serious. Plastic waste flows into the ocean. Dangerous. Reduce plastic bags for the next generation.
4, Serious environmental issues. Plastic flows to the ocean. Dangerous for animals. We must reduce bags and bottles for the future.
4, Plastic waste is a serious issue. It flows into the ocean. Dangerous for sea animals. We must reduce plastic bags. Protect environment for the next generation.
4, Environmental issues. Plastic flows into the ocean. Dangerous. Reduce bags. Next generation.
3, Plastic waste is serious. Flows into the ocean. Dangerous for sea animals. We must reduce plastic bags and bottles.
3, Environmental issues are serious. Plastic in the ocean. Animals eat it. Dangerous. We must reduce plastic bags.
3, Plastic waste flows into the ocean. It is dangerous for animals. We should reduce plastic bags.
3, Environmental issues. Plastic waste in the ocean. Sea animals eat it. Dangerous. Reduce plastic bags.
3, Plastic flows to the ocean. Dangerous for sea animals. We must reduce bags.
3, Plastic waste is a serious problem. Ocean. Animals. Dangerous. Reduce plastic bottles.
3, Environmental issues serious. Plastic ocean. Dangerous animals. Reduce plastic.
3, Plastic flows into the ocean. It is dangerous. We must reduce bags.
3, Plastic waste serious. Ocean. Animals eat. Dangerous. Reduce.
3, Plastic in the sea. Dangerous for animals. We must reduce plastic bags.
3, Environmental issues. Plastic in the ocean. Dangerous. Reduce plastic.
3, Plastic waste. Ocean. Dangerous for sea animals. Reduce bags.
3, Plastic flows into the ocean. Animals eat it. Dangerous. Reduce.
2, Plastic waste in the ocean. Dangerous for animals. Reduce bags.
2, Plastic in the ocean. Dangerous. Reduce plastic bags.
2, Plastic waste flows to ocean. Dangerous. Reduce.
2, Environmental serious. Plastic ocean. Dangerous.
2, Plastic in the ocean. Animals eat. Dangerous.
2, Plastic waste. Ocean. Dangerous. Reduce.
2, Plastic in the ocean. Dangerous. Reduce.
2, Plastic waste. Sea. Animals. Dangerous.
2, Plastic in the ocean. Dangerous. Reduce.
2, Plastic waste. Ocean. Dangerous.
1, Plastic waste. Ocean.
1, Plastic. Dangerous.
1, Plastic in the ocean.
1, Plastic. Ocean.
1, Plastic. Dangerous.
1, Plastic waste.
1, Sea animals. Plastic.
1, Plastic. Ocean.
1, Plastic waste.
1, Plastic.
```

## 分析の実行と解釈
「分析を実行」ボタンを押すと、画面下部に結果の表が出力されます。

**1. ✅ 定着済（Mastered）**
判定基準: 全体使用率 >= 75%

状態: クラスの約8割の生徒が、自力でその単語をアウトプットできている状態です。

指導への活かし方:
このマークがついた単語（例：ocean や plastic などの基本キーワード）は、**「これ以上、全体に向けて時間を割いて教える必要はない」**という強力なエビデンスになります。先生のインプット指導が大成功した証でもあります。

**2. ⚠️ 格差あり（Gap exists）**
判定基準: 上位層の使用率 - 下位層の使用率 >= 40% （※定着済の条件から漏れたもの）

状態: 英語が得意な上位層は使いこなしている一方で、苦手な下位層は明確に避けている単語です。

指導への活かし方:
ここがこのツールで最も価値のある発見になります。例えば environmental や generation のような、文字数が長かったり発音が難しい単語がここに分類されやすくなります。
「上位層は言えているのだから、教え方は間違っていない。ただ、下位層には想起のハードルが高い」と分析できるため、次回の授業で下位層向けのヒントカードにこの単語を意図的に忍ばせるといった、個別最適な支援（ピンポイントな介入）のターゲットになります。

**3. ❌ 未定着（Unestablished）**
判定基準: 全体使用率 < 30%

状態: クラスの7割以上の生徒が発話できなかった単語です。

指導への活かし方:
先生が「理想の要約」に入れた（＝言えなきゃダメだと思っていた）にも関わらず、全体が使えていない状態です。これは生徒の責任というより、**「インプット時の印象付けが弱かった」か、「生徒の現在のレベルに対して単語の難易度が高すぎた」**という教材・指導側の課題として受け止めることができます。次回の帯活動などで、クラス全体への再指導（フラッシュカードでの反復など）が必要です。

**4. - 定着の途上（Developing）**
判定基準: 上記のどれにも当てはまらない（例：全体使用率が40%〜70%で、上下の格差も激しくない）

状態: クラスの中に「じわじわと浸透しつつある」最中の単語です。

指導への活かし方:
極端な格差はないため、特別な個別フォローや手厚い再指導は不要です。単純にペアワークの回数を増やし、クラスメイト同士の発話を聞き合う（ピア・インタラクション）機会を設けるだけで、自然と「✅ 定着済」へと押し上げられる可能性が高い単語群です。

