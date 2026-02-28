---
title: "【校務効率化】クラス全員のスピーキングテストの結果を1秒で可視化する魔法（GAS編）"
emoji: "📊"
type: "tech"
topics: ["googleappsscript", "教育", "英語教育", "スプレッドシート", "DX"]
published: true
---


## はじめに
学校現場の先生方、毎日の業務本当にお疲れ様です。

英語科の先生方、スピーキングテストの観点別評価を生徒にフィードバックする際、「数字の羅列じゃなくて、図（レーダーチャート）にして可視化したい」と思ったことはありませんか？

でも、仮に1クラス40人のクラスサイズだとして、生徒40人分のグラフをExcelやスプレッドシートで一つずつ手作業で作るのは、想像しただけで心が折れますよね。しかし、この手間のせいで、スピーキングテストを実施しない、あるいは実施したとしても、通知表の成績に反映させるだけで生徒にフィードバックできないのは非常にもったいないと感じます。

今回は、**プログラミングの知識がゼロでも、コピペだけで「一瞬で生徒の成績グラフが切り替わる魔法のダッシュボード」を作る方法**を共有します。

## 今回作るもの（完成イメージ）

まず、1枚のシートに全ての生徒のスピーキングテストの各観点スコア表を作成します。



![](https://storage.googleapis.com/zenn-user-upload/998627f0ad03-20260228.png)




＞そして、「グラフ作成」というボタンを押すだけで、「個人分析」というシートが出来上がります。



![](https://storage.googleapis.com/zenn-user-upload/4aab0c999b52-20260228.png)



＞そのシート内の右上にある「氏名」のプルダウンを切り替えると……



![](https://storage.googleapis.com/zenn-user-upload/0f6008ea1bce-20260228.gif)


**一瞬で、その生徒の点数と「上向き三角形の綺麗なレーダーチャート」がパッと切り替わります！**

これなら、タブが40個も並んでごちゃごちゃすることもありませんし、この画面を1枚ずつ印刷すればそのまま生徒への返却用シートになります。更に、先生方もそれぞれの生徒の強みや弱点を把握しやすく、次の指導に生かせそうです。

## 準備するもの
* Googleアカウント
* Googleスプレッドシート

## 作り方（たったの3ステップ）

### ステップ1：名簿データの準備
1. 新しいスプレッドシートを作成し、シートの名前（左下のタブ）を **「名簿」** に変更します。
2. 1行目に「氏名」と「先生方が設けた観点」を入力します。（私のでは、デモとして、「語彙・文法」「流暢さ」「発音」を設けました）
3. 2行目以降に、生徒の名前とスコアを入力します。

### ステップ2：魔法のコードをコピペ
1. 上のメニューから **「拡張機能」 ＞ 「Apps Script」** をクリックします。
2. 最初から書かれている文字（`function myFunction() {...}`）をすべて消します。
3. 以下のコードを丸ごとコピーして、貼り付けます。

```javascript
/**
 * プルダウンで切り替わる個人分析ダッシュボードを自動生成する関数
 * （任意の観点数に対応、クラス平均との比較チャート付き）
 */
function createDashboard() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const mainSheetName = "名簿"; 
  const mainSheet = ss.getSheetByName(mainSheetName);

  // 元データシートの存在確認
  if (!mainSheet) {
    Browser.msgBox("「" + mainSheetName + "」という名前のシートが見つかりません。");
    return;
  }

  // 観点（列）が入力されているか確認
  const lastCol = mainSheet.getLastColumn();
  if (lastCol < 2) {
    Browser.msgBox("観点が入力されていません。");
    return;
  }
  
  const headers = mainSheet.getRange(1, 1, 1, lastCol).getValues()[0];
  const allData = mainSheet.getDataRange().getValues();
  
  // チャートの最大値を自動検出
  let globalMax = 0;
  for (let r = 1; r < allData.length; r++) {
    for (let c = 1; c < allData[r].length; c++) {
      const score = Number(allData[r][c]);
      if (!isNaN(score) && score > globalMax) {
        globalMax = score;
      }
    }
  }
  if (globalMax === 0) globalMax = 5; // データが空の場合はデフォルトで5を設定

  // ダッシュボードシートの初期化（既存があれば再作成）
  const dashboardName = "個人分析"; 
  let dashboardSheet = ss.getSheetByName(dashboardName);

  if (dashboardSheet) {
    ss.deleteSheet(dashboardSheet);
  }
  dashboardSheet = ss.insertSheet(dashboardName);

  // 氏名選択用プルダウンの作成
  const nameCell = dashboardSheet.getRange("B1");
  dashboardSheet.getRange("A1").setValue("▼ 氏名を選択").setFontWeight("bold").setBackground("#cfe2f3");
  
  const rule = SpreadsheetApp.newDataValidation()
    .requireValueInRange(mainSheet.getRange("A2:A"), true)
    .build();
  nameCell.setDataValidation(rule).setBackground("#fff2cc");

  // 初期値として名簿の1人目をセット
  const firstStudent = mainSheet.getRange("A2").getValue();
  if (firstStudent) {
    nameCell.setValue(firstStudent);
  }

  // 各観点のデータ取得用数式を生成
  let criteriaList = [];
  for (let i = 1; i < headers.length; i++) {
    const criteriaName = headers[i];
    if (!criteriaName) continue; 

    const colIndex = i + 1; 
    const colLetter = String.fromCharCode(64 + colIndex); 
    
    const scoreFormula = `=IFERROR(VLOOKUP($B$1, '${mainSheetName}'!$A:$Z, ${colIndex}, FALSE), 0)`;
    const averageFormula = `=IFERROR(ROUND(AVERAGE('${mainSheetName}'!$${colLetter}:$${colLetter}), 1), 0)`; 
    
    criteriaList.push({
      name: criteriaName,
      score: scoreFormula,
      average: averageFormula
    });
  }

  const tableStartRow = 3; 

  // データ表の見出し行を作成
  // ※グラフの誤認識（不要な頂点の発生）を防ぐため、左上セルは意図的に空欄にしています
  dashboardSheet.getRange(tableStartRow, 1).setValue(""); 
  dashboardSheet.getRange(tableStartRow, 2).setFormula('=$B$1 & " さんの成績"');
  dashboardSheet.getRange(tableStartRow, 3).setValue("クラス平均");

  dashboardSheet.getRange(tableStartRow, 1, 1, 3).setBackground("#d9ead3").setFontWeight("bold");

  // データ表の書き込み
  let tableData = []; 
  criteriaList.forEach(c => {
    tableData.push([c.name, c.score, c.average]);
  });
  
  const dataRowsCount = tableData.length;
  const totalRowsCount = dataRowsCount + 1; 
  const tableEndRow = tableStartRow + totalRowsCount - 1; 

  if (dataRowsCount > 0) {
    dashboardSheet.getRange(tableStartRow + 1, 1, dataRowsCount, 3).setValues(tableData);
  }

  // 表の装飾とレイアウト調整
  dashboardSheet.getRange(tableStartRow, 1, totalRowsCount, 3).setBorder(true, true, true, true, true, true);
  dashboardSheet.getRange(tableStartRow + 1, 2, dataRowsCount, 2).setHorizontalAlignment("center");
  
  dashboardSheet.setColumnWidth(1, 120); 
  dashboardSheet.setColumnWidth(2, 140); 
  dashboardSheet.setColumnWidth(3, 100);

  // グラフ生成前にシート上の数式計算を完了させる
  SpreadsheetApp.flush();

  const chartDataRange = dashboardSheet.getRange(tableStartRow, 1, totalRowsCount, 3); 

  // レーダーチャートの生成と配置
  const chartBuilder = dashboardSheet.newChart()
    .setChartType(Charts.ChartType.RADAR)
    .addRange(chartDataRange)
    .setPosition(tableEndRow + 2, 1, 0, 0) 
    .setOption('title', "スピーキングテスト評価")
    .setOption('width', 480)  
    .setOption('height', 360) 
    .setOption('chartArea', {left: '10%', top: '15%', width: '80%', height: '60%'}) 
    .setOption('vAxis.minValue', 0)
    .setOption('vAxis.maxValue', globalMax) 
    .setOption('legend', {position: 'bottom', textStyle: {fontSize: 12}}) 
    .setNumHeaders(1) // 範囲の1行目を凡例ラベルとして強制認識
    .setOption('useFirstColumnAsDomain', true) 
    .setOption('series', {
      0: { color: '#4285F4', lineWidth: 3, pointSize: 5 }, // 本人の成績（青・実線）
      1: { color: '#FF9900', lineWidth: 2, lineDashStyle: [4, 4], pointSize: 0 } // クラス平均（オレンジ・点線）
    })
    .build();

  dashboardSheet.insertChart(chartBuilder);
  
 Browser.msgBox("完成しました！「個人分析」シートのB1セルのプルダウンを切り替えてみてください。");
}
```


画面上部の **「保存（フロッピーディスクのアイコン）」** を押します。

### ステップ3：いざ実行！（※最初だけ注意点あり）
スプレッドシートの画面に戻ります。

メニューの **「挿入」＞「図形描画」**で適当な図形を作り、「チャート作成」と文字を入力して保存します。

シートに現れた図形の右上にある「**︙**（点が3つのマーク）」を押し、**「スクリプトを割り当て」** を選びます。

**createDashboard **と入力してOKを押します。

## 【⚠️重要：初回実行時の「赤い警告」について】
初めてボタンを押した時、「承認が必要です」という画面や、「このアプリはGoogleで確認されていません」という怖い赤い警告が出ます。

![](https://storage.googleapis.com/zenn-user-upload/dcc1b6c574ac-20260228.png)

これは「あなたが作ったプログラムが、あなたのシートを操作してもいいですか？」という確認の儀式です。ウイルスではないので安心してください。

乗り越え方：
左下の **「詳細」** という小さな文字をクリック → 一番下に出てくる **「無題のプロジェクト（安全ではない）に移動」** をクリック → **「許可」** を押す。

## おわりに
これで完成です！
新しくできた「個人分析」シートの黄色いマス（B1セル）をクリックして、別の生徒を選んでみてください。一瞬でグラフが切り替わる感動を味わえるはずです。

仮に生徒数や観点、スコア段階が増えたり減ったりしても、しっかりとチャートが作れるような工夫をしています。
空いているスペースに「先生からのコメント」欄を書き足せば、立派な面談資料の完成です。

**実際に使ってみた感想や、「もっとこんな機能がほしい！」等ございましたら遠慮なくお伝え下さい！**

テクノロジーの力で、生徒の英語力が向上し、かつ先生方の放課後が少しでも早く終わりますように！

