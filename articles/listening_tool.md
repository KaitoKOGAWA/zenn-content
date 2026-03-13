---
title: "【HTML/JS】AIの英語読み上げを更にナチュラルに。Web Speech APIを応用した英語リスニング教材スタジオ"
emoji: "🎧"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SLA", "英語教育", "javascript", "教材作成", "音声合成","教育","AI"]
published: true
---

## 開発の意図：AIの不自然な読み上げを卒業する
リーディングテキストをリスニング教材にする際に用いられるTTS（Text-to-Speech）は、実際のコミュニケーションで発生する「言い淀み（Fillers）」や「ため（Pauses）」が欠如しがちです。


本ツールは、AIの読み上げをよりリアルな英語に近づけたいという思いから開発されました。

## 本ツールの3つの特徴
① **ナチュラルなフィラーの自動挿入**
um や well など、「フィラー」を入力するだけで、AIがリアルな英語発話でよくある「今、言いたいことを探している」ような絶妙な間をシミュレートします。（フィラーの間や発話速度については、こちらで可能な限り自然になるような調整がなされています）

### 💡 リズムを支配する「カンマ」の使い分け
このツールは、カンマ（,）を単なる句読点ではなく、「**0.5秒の無音区間（ポーズ）**」として処理します。意図に合わせて入力を調整してください。


Tips: > リスニング試験の選択肢文など、淀みなく提示したい場合は、本来の英文法で必要なカンマであっても、あえて「**削除**」して入力するのがコツです。


② **発話速度の最適化**
「初級」から「超上級」まで、ボタンひとつでリスニング評価に最適な発話速度を調整可能です。

③ **環境音（BGM）の合成機能**
試験会場の雑音や、カフェの環境音を合成して録音できます。これにより、ノイズに対する耐性を養うリスニングテストの作成が容易になります。適宜、自身で.mpファイルを付けてご使用ください。


## 準備と使い方（30秒）
プログラミングの知識は不要です。

①以下のソースコードをすべてコピーします。

②パソコンの「メモ帳」等に貼り付け、 listening_studio.html という名前で保存します。

③保存したファイルをブラウザ（Google Chrome推奨）で開けば、即座に使用可能です。

```html
<!DOCTYPE html><html lang="ja"><head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>リスニング教材作成スタジオ</title>
    <style>
        body { font-family: 'Meiryo', sans-serif; background-color: #f4f7f6; padding: 20px; color: #333; }
        .container { max-width: 850px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; border-bottom: 3px solid #3498db; padding-bottom: 15px; margin-bottom: 25px; }
        label { font-weight: bold; margin-top: 20px; display: block; color: #2c3e50; }
        textarea { width: 100%; height: 180px; font-size: 16px; padding: 15px; margin-top: 8px; border: 2px solid #ddd; border-radius: 8px; box-sizing: border-box; transition: 0.3s; }
        textarea:focus { border-color: #3498db; outline: none; }
        .settings-group { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-top: 20px; border: 1px solid #eee; }
        .speed-options label { font-weight: normal; margin-right: 15px; display: inline-block; cursor: pointer; padding: 8px 0; }
        .buttons { text-align: center; margin-top: 30px; }
        button { font-size: 18px; padding: 12px 25px; margin: 8px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; transition: 0.3s; }
        #playBtn { background-color: #27ae60; color: white; }
        #recordBtn { background-color: #e67e22; color: white; padding: 18px 40px; font-size: 22px; border: 2px solid #d35400; }
        #stopBtn { background-color: #95a5a6; color: white; }
        .hint { font-size: 0.85em; color: #7f8c8d; margin-top: 8px; line-height: 1.5; }
        .status-area { height: 40px; margin-top: 15px; text-align: center; }
        #recordingStatus { color: #e74c3c; font-weight: bold; display: none; animation: blink 1s infinite; }
        #delayStatus { color: #3498db; font-weight: bold; display: none; }
        @keyframes blink { 50% { opacity: 0; } }
    </style></head><body><div class="container">
    <h1>🎧 リスニング教材スタジオ</h1>
    
    <label for="textToSpeak">読み上げる英文</label>
    <textarea id="textToSpeak" placeholder="英文を入力してください。例: Hello, everyone. Today I want to talk about, well, our future plan."></textarea>
    <p class="hint">
        💡 <strong>使い方のコツ：</strong> <br>
        「um, well, you know」等は自動で長めのポーズを入れます。「Actually, I mean」はカンマを打った時だけ短くポーズを取り、発音も強調されます。
    </p>

    <div class="settings-group">
        <label>🗣️ 音声（品質安定版）</label>
        <p class="hint" style="margin-top:0;">※ポーズ感が最も安定する音声エンジンを表示しています。</p>
        <select id="voiceSelect" style="width: 100%; padding: 10px; margin-top: 8px; border-radius: 5px; font-size: 16px;"></select>

        <label>🏃 読み上げスピード</label>
        <div class="speed-options">
            <label><input type="radio" name="speed" value="0.4"> 初級</label>
            <label><input type="radio" name="speed" value="0.53" checked> 中級</label>
            <label><input type="radio" name="speed" value="0.67"> 上級</label>
            <label><input type="radio" name="speed" value="0.8"> 超上級</label>
        </div>
    </div>

    <div class="settings-group">
        <label>🏫 背景の雑音（環境音）</label>
        <input type="file" id="bgmFile" accept="audio/*">
        <label style="font-weight: normal; margin-top: 10px;">音量調整: <input type="range" id="bgmVolume" min="0" max="1" step="0.1" value="0.3"></label>
    </div>

    <div class="status-area">
        <div id="delayStatus">⏳ 待機中... (あと 3秒)</div>
        <div id="recordingStatus">⏺ 録音中...</div>
    </div>

    <div class="buttons">
        <button id="playBtn">▶ 再生</button>
        <button id="stopBtn">■ 停止</button>
        <br>
        <button id="recordBtn">⏺ 録音して保存</button>
    </div></div><script>
    const textInput = document.getElementById('textToSpeak');
    const voiceSelect = document.getElementById('voiceSelect');
    const speedOptions = document.getElementsByName('speed');
    const bgmFileInput = document.getElementById('bgmFile');
    const bgmVolumeInput = document.getElementById('bgmVolume');
    const playBtn = document.getElementById('playBtn');
    const stopBtn = document.getElementById('stopBtn');
    const recordBtn = document.getElementById('recordBtn');
    const recordingStatus = document.getElementById('recordingStatus');
    const delayStatus = document.getElementById('delayStatus');

    const synth = window.speechSynthesis;
    let voices = [];
    let bgmAudio = new Audio(); 
    bgmAudio.loop = true;
    let mediaRecorder;
    let recordedChunks = [];
    let stream;
    let delayTimer;

    const LONG_FILLERS = ["let me see", "you know", "like", "well", "umm", "um", "uh"];
    const SHORT_FILLERS = ["actually", "i mean"];

    function getVendorTag(voiceName) {
        if (voiceName.includes('Google')) return '[Google製]';
        if (voiceName.includes('Microsoft')) return '[Microsoft製]';
        if (voiceName.includes('Siri') || voiceName.includes('Apple')) return '[Apple製]';
        return '[標準内蔵]';
    }

    function populateVoiceList() {
        voices = synth.getVoices();
        voiceSelect.innerHTML = ''; 
        let englishVoices = voices.filter(voice => voice.lang.startsWith('en'));

        let targetVendor = null;
        for (const voice of englishVoices) {
            if (voice.lang.toLowerCase().includes('us')) {
                const nameLower = voice.name.toLowerCase();
                const isMale = ['male', 'david', 'mark', 'daniel', 'arthur', 'alex', 'fred', 'james', 'george', 'william'].some(n => nameLower.includes(n));
                if (isMale) {
                    targetVendor = getVendorTag(voice.name);
                    break; 
                }
            }
        }

        if (targetVendor) {
            englishVoices = englishVoices.filter(voice => getVendorTag(voice.name) === targetVendor);
        }

        const regionMap = {
            'US': '🇺🇸 アメリカ', 'GB': '🇬🇧 イギリス', 'AU': '🇦🇺 オーストラリア',
            'IN': '🇮🇳 インド', 'SG': '🇸🇬 シンガポール', 'ZA': '🇿🇦 南アフリカ',
            'NG': '🇳🇬 ナイジェリア', 'KE': '🇰🇪 ケニア', 'IE': '🇮🇪 アイルランド',
            'NZ': '🇳🇿 ニュージーランド', 'PH': '🇵🇭 フィリピン', 'CA': '🇨🇦 カナダ',
            'TZ': '🇹🇿 タンザニア'
        };

        const targets = {};

        englishVoices.forEach(voice => {
            let regionCode = voice.lang.split(/[-_]/)[1];
            if (!regionCode) return;
            regionCode = regionCode.toUpperCase();

            if (!targets[regionCode]) {
                targets[regionCode] = { label: regionMap[regionCode] || `🌐 その他 (${regionCode})`, male: null, female: null };
            }

            const nameLower = voice.name.toLowerCase();
            let isMale = ['male', 'david', 'mark', 'daniel', 'arthur', 'alex', 'fred', 'james', 'george', 'william'].some(n => nameLower.includes(n));
            let isFemale = ['female', 'zira', 'samantha', 'victoria', 'karen', 'tessa', 'moira', 'susan', 'lisa', 'ava', 'google'].some(n => nameLower.includes(n));

            if (!isMale && !isFemale) {
                if (!targets[regionCode].female) isFemale = true;
                else if (!targets[regionCode].male) isMale = true;
            }

            if (isFemale && !targets[regionCode].female) targets[regionCode].female = voice;
            else if (isMale && !targets[regionCode].male) targets[regionCode].male = voice;
        });

        Object.values(targets).forEach(target => {
            if (target.female) {
                const opt = document.createElement('option');
                opt.textContent = `${target.label} (女性) - ${target.female.name.split(' ')[0]} ${getVendorTag(target.female.name)}`;
                opt.setAttribute('data-name', target.female.name);
                voiceSelect.appendChild(opt);
            }
            if (target.male) {
                const opt = document.createElement('option');
                opt.textContent = `${target.label} (男性) - ${target.male.name.split(' ')[0]} ${getVendorTag(target.male.name)}`;
                opt.setAttribute('data-name', target.male.name);
                voiceSelect.appendChild(opt);
            }
        });

        if (voiceSelect.options.length === 0) {
            voiceSelect.innerHTML = '<option>英語の音声が見つかりません</option>';
        } else {
            for (let i = 0; i < voiceSelect.options.length; i++) {
                if (voiceSelect.options[i].text.includes('🇺🇸 アメリカ (男性)')) {
                    voiceSelect.selectedIndex = i;
                    break;
                }
            }
        }
    }

    populateVoiceList();
    if (speechSynthesis.onvoiceschanged !== undefined) {
        speechSynthesis.onvoiceschanged = populateVoiceList;
    }

    bgmFileInput.addEventListener('change', function(e) {
        if (e.target.files[0]) {
            bgmAudio.src = URL.createObjectURL(e.target.files[0]);
            bgmAudio.volume = bgmVolumeInput.value;
        }
    });
    bgmVolumeInput.addEventListener('input', function() { bgmAudio.volume = this.value; });

    function getProcessedText(rawText) {
        let text = rawText;

        LONG_FILLERS.forEach(filler => {
            const regexBoth = new RegExp(`,\\s*(${filler})\\s*,`, 'gi');
            text = text.replace(regexBoth, "... $1... ");
            const regexAfter = new RegExp(`\\b(${filler})\\s*,`, 'gi');
            text = text.replace(regexAfter, "$1... ");
            const regexBefore = new RegExp(`,\\s*(${filler})\\b`, 'gi');
            text = text.replace(regexBefore, "... $1 ");
        });

        SHORT_FILLERS.forEach(filler => {
            const regexBoth = new RegExp(`,\\s*(${filler})\\s*,`, 'gi');
            text = text.replace(regexBoth, " __COMMA__ $1 __COMMA__ ");
            const regexAfter = new RegExp(`\\b(${filler})\\s*,`, 'gi');
            text = text.replace(regexAfter, "$1 __COMMA__ ");
            const regexBefore = new RegExp(`,\\s*(${filler})\\b`, 'gi');
            text = text.replace(regexBefore, " __COMMA__ $1 ");
        });

        text = text.replace(/,/g, " ").replace(/__COMMA__/g, ",");
        text = text.replace(/\byou know\b/gi, "y'KNOW");
        text = text.replace(/\bi mean\b/gi, "I MEAN");

        return text.replace(/\s+/g, " ").trim();
    }

    async function startProcess(isRecordingMode = false) {
        const rawText = textInput.value.trim();
        if (!rawText) return alert("英文を入力してください");
        synth.cancel();
        clearTimeout(delayTimer);
        const processedText = getProcessedText(rawText);
        const utterThis = new SpeechSynthesisUtterance(processedText);
        const selectedVoiceName = voiceSelect.options[voiceSelect.selectedIndex].getAttribute('data-name');
        const selectedVoice = voices.find(v => v.name === selectedVoiceName);
        if (selectedVoice) utterThis.voice = selectedVoice;
        let speed = 1.0;
        for (const opt of speedOptions) { if (opt.checked) speed = parseFloat(opt.value); }
        utterThis.rate = speed;
        utterThis.onend = () => {
            bgmAudio.pause();
            bgmAudio.currentTime = 0;
            if (isRecordingMode && mediaRecorder && mediaRecorder.state !== 'inactive') mediaRecorder.stop();
            delayStatus.style.display = 'none';
        };
        if (bgmAudio.src) bgmAudio.play();
        delayStatus.style.display = 'block';
        let countdown = 3;
        const countInterval = setInterval(() => {
            countdown--;
            if (countdown > 0) { delayStatus.innerText = `⏳ 待機中... (あと ${countdown}秒)`; }
            else { clearInterval(countInterval); delayStatus.style.display = 'none'; }
        }, 1000);
        delayTimer = setTimeout(() => { synth.speak(utterThis); }, 3000);
    }

    playBtn.addEventListener('click', () => startProcess(false));
    stopBtn.addEventListener('click', () => {
        synth.cancel(); bgmAudio.pause(); bgmAudio.currentTime = 0; clearTimeout(delayTimer);
        if (mediaRecorder && mediaRecorder.state !== 'inactive') mediaRecorder.stop();
        delayStatus.style.display = 'none'; recordingStatus.style.display = 'none';
    });

    recordBtn.addEventListener('click', async () => {
        try {
            alert('【録音の準備】\n次の画面で「タブ」を選択し、必ず「タブの音声を共有」にチェックを入れてください。');
            stream = await navigator.mediaDevices.getDisplayMedia({ video: true, audio: true });
            const audioTrack = stream.getAudioTracks()[0];
            if (!audioTrack) { stopRecording(); return; }
            mediaRecorder = new MediaRecorder(new MediaStream([audioTrack]));
            recordedChunks = [];
            mediaRecorder.ondataavailable = e => { if (e.data.size > 0) recordedChunks.push(e.data); };
            mediaRecorder.onstop = () => {
                const blob = new Blob(recordedChunks, { type: 'audio/webm' });
                const a = document.createElement('a');
                a.href = URL.createObjectURL(blob);
                a.download = 'listening_audio.webm';
                a.click();
                stopRecording();
            };
            mediaRecorder.start();
            recordingStatus.style.display = 'block';
            recordBtn.disabled = true;
            startProcess(true);
        } catch (err) { stopRecording(); }
    });

    function stopRecording() {
        if (stream) stream.getTracks().forEach(t => t.stop());
        recordingStatus.style.display = 'none';
        recordBtn.disabled = false;
        delayStatus.style.display = 'none';
    }</script></body></html>
```

完成した.htmlファイルを開くと、このような画面が出てくると思います。



#### 練習用テキスト
ツールの動作確認のために、よろしければ以下のテキストをコピペしてお使いください。
```text
Hello, everyone. Um, today I want to talk about our school festival. We have a lot of ideas, but, well, we haven't decided what to do yet. I was thinking about a cafe, but, you know, it might be too much work. Uh, maybe we can do a haunted house instead. It's, like, really popular every year. Umm, but we need a lot of materials for that. Actually, I have some cardboard boxes at home. So, I mean, we just need to buy some paint. Let me see, what else do we need?
```


#### 発話速度と英語の選択
汎用性の高さを目指し、発話速度は初級者向けのゆっくりとしてものから超上級者向けの比較的速いものまで準備しました。
更に、英語の種類もアメリカ英語やイギリス英語に限らず、豊富な種類をご用意しました。近年はWorld Englishesの考えが広まっているため、非ネイティブ以外の豊富な種類の英語に触れることは非常に重要です。


#### 背景音（BGM）の推奨ソース
教材に臨場感を出すための環境音は、以下のサイトから「カフェ」や「教室」の音をダウンロードして使用するのがおすすめです。

**効果音ラボ**: 「生活音」カテゴリに教室や喫茶店の音があります。

**OtoLogic**: 「環境音」カテゴリが充実しています。


また、効果音の音量は調整することが出来ます。



#### 実際にどんなものができる？
こちらに実際に出来た音声ファイルを載せました。ぜひ聞いてみてください。
設定は、

**音声→「us アメリカ（男性）-Microsoft[Microsoft製]」**

**読み上げスピード→上級**

**背景の雑音（環境音）→「騒がしい高校の教室.mp3」（効果音ラボより）**

"https://raw.githubusercontent.com/KaitoKOGAWA/audio/main/listening.demo.webm"

## まとめ
いかがでしたか？まだまだ粗いところが多くありますが、AIの読み上げを可能な限りリアルな英語発話に近づけたいという思いを少しは形にできたと感じます。

今後は、モノローグに限らず、2人以上の人が話すダイアローグ形式にも対応できるようにツールの開発を進めていきたいと思います。

使ってみての感想、ご要望等ございましたら、コメントでお知らせください。
