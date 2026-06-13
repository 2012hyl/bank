<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover"/>
  <title>贷款预审 · AI助手</title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif}
    body{background:#f5f7fa;min-height:100dvh;display:flex;justify-content:center;padding:16px}
    .container{width:100%;max-width:420px;display:flex;flex-direction:column;gap:14px}
    .card{background:#fff;border-radius:16px;padding:18px;box-shadow:0 2px 12px rgba(0,0,0,0.06)}
    .card h2{font-size:17px;color:#1a1a2e;margin-bottom:12px;display:flex;align-items:center;gap:8px}
    .card h2 span{font-size:22px}
    label{font-size:13px;color:#666;display:block;margin-bottom:4px;margin-top:10px}
    label:first-of-type{margin-top:0}
    input,select{width:100%;padding:10px 14px;border:1px solid #e0e0e0;border-radius:10px;font-size:15px;outline:none;background:#fafafa;color:#333}
    input:focus,select:focus{border-color:#4a6cf7;background:#fff}
    .btn{width:100%;padding:14px;background:#4a6cf7;color:#fff;border:none;border-radius:12px;font-size:16px;font-weight:600;cursor:pointer;transition:all 0.2s}
    .btn:hover{background:#3b5de7;transform:translateY(-1px)}
    .btn:active{transform:scale(0.97)}
    .btn:disabled{background:#ccc;cursor:not-allowed}
    .result-box{background:#f8faff;border:2px solid #4a6cf7;border-radius:14px;padding:16px;margin-top:8px;display:none;line-height:1.8;font-size:14px;color:#333;white-space:pre-line}
    .result-box.show{display:block;animation:fadeIn 0.3s ease}
    .disclaimer{text-align:center;color:#aaa;font-size:11px;margin-top:8px}
    .tab-bar{display:flex;gap:8px}
    .tab{flex:1;padding:10px;text-align:center;background:#fff;border-radius:10px;font-size:13px;color:#666;cursor:pointer;border:1px solid #e0e0e0;transition:all 0.2s}
    .tab.active{background:#4a6cf7;color:#fff;border-color:#4a6cf7}
    .tool-card{display:none}
    .tool-card.active{display:block}
    @keyframes fadeIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
  </style>
</head>
<body>
<div class="container">
  <div style="text-align:center;padding:8px 0">
    <h1 style="font-size:22px;color:#1a1a2e">🏦 AI贷款预审助手</h1>
    <p style="font-size:12px;color:#999;margin-top:4px">银行内部逻辑 · 输入信息 · 秒出结果</p>
  </div>

  <div class="tab-bar">
    <div class="tab active" onclick="switchTab('precheck')">📋 贷款预审</div>
    <div class="tab" onclick="switchTab('compare')">📊 银行对比</div>
    <div class="tab" onclick="switchTab('translate')">📖 术语翻译</div>
  </div>

  <!-- 贷款预审 -->
  <div class="card tool-card active" id="tab-precheck">
    <h2><span>📋</span>贷款预审</h2>
    <label>月收入（元）</label>
    <input type="number" id="income" placeholder="比如：8000">

    <label>征信情况</label>
    <select id="credit">
      <option value="good">良好 · 无逾期</option>
      <option value="minor">轻微 · 有过1-2次短期逾期</option>
      <option value="bad">较差 · 有多次逾期记录</option>
    </select>

    <label>想贷多少（元）</label>
    <input type="number" id="amount" placeholder="比如：200000">

    <label>贷款用途</label>
    <select id="purpose">
      <option value="消费贷">消费贷 · 日常消费</option>
      <option value="经营贷">经营贷 · 做生意/创业</option>
      <option value="房贷">房贷 · 买房</option>
      <option value="车贷">车贷 · 买车</option>
      <option value="信用贷">信用贷 · 无抵押</option>
    </select>

    <label>工作年限</label>
    <select id="workYears">
      <option value="less1">不到1年</option>
      <option value="1-3">1-3年</option>
      <option value="3-5" selected>3-5年</option>
      <option value="5+">5年以上</option>
    </select>

    <button class="btn" id="precheckBtn" onclick="runPrecheck()">🔍 开始预审</button>
    <div class="result-box" id="precheckResult"></div>
  </div>

  <!-- 银行对比 -->
  <div class="card tool-card" id="tab-compare">
    <h2><span>📊</span>银行产品对比</h2>
    <label>贷款类型</label>
    <select id="compareType">
      <option value="消费贷">消费贷</option>
      <option value="房贷">房贷</option>
      <option value="经营贷">经营贷</option>
    </select>
    <button class="btn" onclick="runCompare()">📊 查看对比</button>
    <div class="result-box" id="compareResult"></div>
  </div>

  <!-- 术语翻译 -->
  <div class="card tool-card" id="tab-translate">
    <h2><span>📖</span>术语翻译器</h2>
    <label>输入银行术语</label>
    <input type="text" id="termInput" placeholder="比如：等额本息、LPR、提前还款违约金">
    <button class="btn" onclick="runTranslate()">🔍 翻译</button>
    <div class="result-box" id="translateResult"></div>
  </div>

  <p class="disclaimer">⚠️ 本工具仅供参考，不构成任何贷款建议。具体贷款条件以银行实际审批为准。</p>
  <p style="text-align:center;color:#ccc;font-size:10px;margin-top:-6px">由 DeepSeek V4 提供AI支持 · 14岁开发者独立制作</p>
</div>

<script>
const WORKER_URL = "https://51ai-1.pages.dev/api/proxy";
const MODEL = "deepseek-v4-flash";

function switchTab(tab){
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.tool-card').forEach(t => t.classList.remove('active'));
  event.target.classList.add('active');
  document.getElementById('tab-' + tab).classList.add('active');
}

async function callAI(prompt){
  try{
    const res = await fetch(WORKER_URL, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        model: MODEL,
        messages: [{role:'user', content: prompt}],
        temperature: 0.3,
        max_tokens: 400,
        stream: false
      })
    });
    const data = await res.json();
    return data.choices?.[0]?.message?.content || '暂时无法分析，请稍后重试';
  }catch(e){
    return '网络连接失败，请检查网络后重试';
  }
}

async function runPrecheck(){
  const btn = document.getElementById('precheckBtn');
  const resultBox = document.getElementById('precheckResult');
  const income = document.getElementById('income').value || '未填写';
  const credit = document.getElementById('credit').value;
  const amount = document.getElementById('amount').value || '未填写';
  const purpose = document.getElementById('purpose').value;
  const workYears = document.getElementById('workYears').value;

  btn.disabled = true; btn.textContent = '正在分析…';
  resultBox.classList.remove('show');

  const creditMap = {good:'良好，无逾期记录', minor:'轻微，有过1-2次短期逾期', bad:'较差，有多次逾期记录'};
  const workMap = {less1:'不到1年', '1-3':'1-3年', '3-5':'3-5年', '5+':'5年以上'};

  const prompt = `你是银行贷款预审专家。根据以下用户信息，给出预估可贷额度范围、预估利率范围、推荐还款期限、需要准备的材料清单、审批通过概率（低/中/高）、注意事项。直接给结论，不说"建议咨询银行"这种废话。

用户信息：
- 月收入：${income}元
- 征信：${creditMap[credit]}
- 想贷金额：${amount}元
- 用途：${purpose}
- 工作年限：${workMap[workYears]}

输出格式：
📊 预估可贷额度：xxx
📈 预估利率：xxx
📅 推荐期限：xxx
📋 需要材料：xxx
🎯 通过概率：xxx
⚠️ 注意：xxx`;

  const result = await callAI(prompt);
  resultBox.textContent = result;
  resultBox.classList.add('show');
  btn.disabled = false; btn.textContent = '🔍 重新预审';
}

function runCompare(){
  const resultBox = document.getElementById('compareResult');
  const type = document.getElementById('compareType').value;

  resultBox.classList.add('show');
  resultBox.textContent = `📊 ${type}主流银行对比（参考数据）

🏦 工商银行：利率3.2%起 · 期限最长30年 · 放款约15工作日
🏦 建设银行：利率3.15%起 · 期限最长30年 · 放款约10工作日
🏦 招商银行：利率3.3%起 · 期限最长20年 · 放款约7工作日
🏦 平安银行：利率3.5%起 · 期限最长15年 · 放款约5工作日
🏦 微众银行：利率3.8%起 · 期限最长5年 · 线上秒批

💡 利率最低：建设银行
💡 放款最快：微众银行
💡 综合推荐：招商银行（利率和放款速度均衡）

⚠️ 以上为公开参考数据，实际以银行审批为准`;
}

async function runTranslate(){
  const term = document.getElementById('termInput').value.trim();
  const resultBox = document.getElementById('translateResult');
  if(!term){ return; }

  resultBox.classList.remove('show');
  const prompt = `你是银行贷款术语翻译专家。用最简单的大白话解释以下术语，让完全不懂金融的人也能听懂。解释控制在2-3句话。术语：${term}`;

  const result = await callAI(prompt);
  resultBox.textContent = result;
  resultBox.classList.add('show');
}
</script>
</body>
</html>
