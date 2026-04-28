const API_BASE = "http://localhost:5000/api";

const MARKETPLACE_EMOJIS = {
  trendyol: "🛍️", amazon: "📦", hepsiburada: "🔶",
  n11: "🟠", pazarama: "🟣", flo: "👟", lcw: "👕"
};

let selectedMarketplace = null;
let selectedDataType    = null;
let selectedFile        = null;

// ── API Sağlık Kontrolü ──
async function checkHealth() {
  const el = document.getElementById("apiStatus");
  try {
    const r = await fetch(`${API_BASE}/health`);
    if (r.ok) {
      el.className = "api-status ok";
      el.innerHTML = '<span class="status-dot"></span><span class="status-text">API Bağlı</span>';
    } else { throw new Error(); }
  } catch {
    el.className = "api-status error";
    el.innerHTML = '<span class="status-dot"></span><span class="status-text">API Bağlanamadı</span>';
  }
}

// ── Pazaryeri Kartlarını Yükle ──
async function loadMarketplaces() {
  try {
    const r    = await fetch(`${API_BASE}/marketplaces`);
    const data = await r.json();
    const grid = document.getElementById("marketplaceGrid");
    grid.innerHTML = "";

    Object.entries(data).forEach(([key, mp]) => {
      const card = document.createElement("div");
      card.className = "marketplace-card";
      card.dataset.key = key;
      card.innerHTML = `<div class="mp-emoji">${MARKETPLACE_EMOJIS[key] || "🏪"}</div><div class="mp-name">${mp.label}</div>`;
      card.addEventListener("click", () => selectMarketplace(key, mp, data));
      grid.appendChild(card);
    });
  } catch(e) {
    console.error("Pazaryeri listesi yüklenemedi:", e);
  }
}

// ── Pazaryeri Seç ──
function selectMarketplace(key, mp, allData) {
  selectedMarketplace = key;
  selectedDataType    = null;
  selectedFile        = null;

  // Kart görselini güncelle
  document.querySelectorAll(".marketplace-card").forEach(c => c.classList.remove("selected"));
  document.querySelector(`.marketplace-card[data-key="${key}"]`).classList.add("selected");

  // Veri tipi listesini doldur
  const list = document.getElementById("dataTypeList");
  list.innerHTML = "";
  allData[key].veri_tipleri.forEach(vt => {
    const item = document.createElement("div");
    item.className = "data-type-item";
    item.dataset.key = vt.key;
    item.textContent = vt.label;
    item.addEventListener("click", () => selectDataType(vt.key));
    list.appendChild(item);
  });

  document.getElementById("dataTypeCard").style.display = "block";
  document.getElementById("uploadCard").style.display   = "none";
  resetUploadState();
}

// ── Veri Türü Seç ──
function selectDataType(key) {
  selectedDataType = key;
  document.querySelectorAll(".data-type-item").forEach(i => i.classList.remove("selected"));
  document.querySelector(`.data-type-item[data-key="${key}"]`).classList.add("selected");
  document.getElementById("uploadCard").style.display = "block";
  resetUploadState();
}

// ── Drop Zone Ayarları ──
function initDropZone() {
  const zone      = document.getElementById("dropZone");
  const fileInput = document.getElementById("fileInput");

  zone.addEventListener("click", () => fileInput.click());

  zone.addEventListener("dragover", e => {
    e.preventDefault();
    zone.classList.add("dragover");
  });
  zone.addEventListener("dragleave", () => zone.classList.remove("dragover"));
  zone.addEventListener("drop", e => {
    e.preventDefault();
    zone.classList.remove("dragover");
    const file = e.dataTransfer.files[0];
    if (file) setFile(file);
  });

  fileInput.addEventListener("change", () => {
    if (fileInput.files[0]) setFile(fileInput.files[0]);
  });
}

function setFile(file) {
  if (!file.name.match(/\.(xlsx|xls)$/i)) {
    showResult(false, "Sadece .xlsx veya .xls dosyaları kabul edilir.");
    return;
  }
  selectedFile = file;
  const sfEl = document.getElementById("selectedFile");
  sfEl.style.display = "flex";
  sfEl.innerHTML = `📄 <strong>${file.name}</strong> &nbsp;(${(file.size/1024).toFixed(1)} KB)`;
  document.getElementById("uploadBtn").disabled = false;
  document.getElementById("resultBox").style.display = "none";
}

// ── Yükleme ──
async function upload() {
  if (!selectedFile || !selectedMarketplace || !selectedDataType) return;

  const btn      = document.getElementById("uploadBtn");
  const progress = document.getElementById("progressWrap");
  const result   = document.getElementById("resultBox");

  btn.disabled = true;
  btn.classList.add("loading");
  document.getElementById("uploadBtnText").textContent = "Yükleniyor...";
  progress.style.display = "flex";
  result.style.display   = "none";

  const form = new FormData();
  form.append("file",        selectedFile);
  form.append("marketplace", selectedMarketplace);
  form.append("data_type",   selectedDataType);

  try {
    const r    = await fetch(`${API_BASE}/upload`, { method: "POST", body: form });
    const data = await r.json();

    progress.style.display = "none";
    btn.classList.remove("loading");
    document.getElementById("uploadBtnText").textContent = "Yükle";

    if (data.basarili) {
      showResult(true, `✅ ${data.mesaj}`);
      loadLogs();
    } else {
      showResult(false, `❌ ${data.hata}`);
    }
  } catch(e) {
    progress.style.display = "none";
    btn.classList.remove("loading");
    document.getElementById("uploadBtnText").textContent = "Yükle";
    showResult(false, `❌ Sunucuya ulaşılamadı: ${e.message}`);
  } finally {
    btn.disabled = false;
  }
}

function showResult(ok, msg, detail = null) {
  const box = document.getElementById("resultBox");
  box.style.display = "block";
  box.className = `result-box ${ok ? "success" : "error"}`;
  box.innerHTML = msg + (detail ? `<div class="error-detail">${detail}</div>` : "");
}

function resetUploadState() {
  selectedFile = null;
  document.getElementById("selectedFile").style.display = "none";
  document.getElementById("fileInput").value = "";
  document.getElementById("uploadBtn").disabled = true;
  document.getElementById("uploadBtnText").textContent = "Yükle";
  document.getElementById("progressWrap").style.display = "none";
  document.getElementById("resultBox").style.display = "none";
}

// ── Log Yükleme ──
async function loadLogs() {
  try {
    const r    = await fetch(`${API_BASE}/logs`);
    const logs = await r.json();
    renderLogs(logs);
  } catch(e) {
    console.error("Loglar yüklenemedi:", e);
  }
}

function renderLogs(logs) {
  const list = document.getElementById("logList");
  if (!logs || logs.length === 0) {
    list.innerHTML = '<div class="log-empty">Henüz yükleme yapılmadı.</div>';
    return;
  }

  list.innerHTML = logs.map(log => {
    const isOk   = log.durum === "basarili";
    const rowTxt = isOk ? `<div class="log-rows">📊 ${log.satir_sayisi} satır eklendi</div>` : "";
    const errTxt = log.hata ? `<div class="log-error-msg">⚠ ${log.hata}</div>` : "";

    return `
      <div class="log-item ${isOk ? "success" : "error"}">
        <div class="log-item-header">
          <span class="log-badge ${isOk ? "success" : "error"}">${isOk ? "✓ Başarılı" : "✗ Hata"}</span>
          <span class="log-time">${log.tarih}</span>
        </div>
        <div class="log-marketplace">${MARKETPLACE_EMOJIS[log.marketplace] || "🏪"} ${log.marketplace.toUpperCase()}</div>
        <div class="log-detail">${log.data_type} · ${log.dosya}</div>
        ${rowTxt}${errTxt}
      </div>
    `;
  }).join("");
}

// ── Init ──
document.getElementById("uploadBtn").addEventListener("click", upload);
document.getElementById("refreshLogsBtn").addEventListener("click", loadLogs);

checkHealth();
loadMarketplaces();
initDropZone();
loadLogs();
