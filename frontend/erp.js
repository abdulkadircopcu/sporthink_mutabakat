const ERP_API = "http://localhost:5000/api";

let erpSelectedKaynak   = null;
let erpSelectedDataType = null;
let erpSelectedFile     = null;

// ── Barkod Uyarı Kontrolü ──
async function erpBarkodUyariYukle() {
  try {
    const r    = await fetch(`${ERP_API}/erp/barkod-uyari`);
    const data = await r.json();

    if (data.hata) return;  // DB boşsa sessizce geç

    const panel = document.getElementById("erpBarkodUyari");
    const acik  = document.getElementById("erpUyariAciklama");
    const tbody = document.getElementById("erpUyariTbody");

    if (!data.uyari_var) {
      panel.style.display = "none";
      return;
    }

    panel.style.display = "block";
    acik.textContent = `${data.eksik_siparis_sayisi} sipariş Hammurlab'da var ama Hitit'te yok — tıkla / detay gör`;

    tbody.innerHTML = data.eksikler.map(e => `
      <tr>
        <td class="mono">${e.takip_no}</td>
        <td class="mono">${e.siparis_no}</td>
        <td>${e.urun_adi}</td>
        <td>${e.marka}</td>
        <td>${e.kaynaklar.map(k => k === "siparisler" ? "📦 Sipariş" : "↩️ İptal/İade").join(", ")}</td>
      </tr>
    `).join("");

  } catch (e) {
    // Sunucu kapalıysa gösterme
  }
}

// ── ERP Kaynaklarını Yükle ──
async function loadErpSources() {
  try {
    const r    = await fetch(`${ERP_API}/erp/sources`);
    const data = await r.json();
    const grid = document.getElementById("erpSourceGrid");
    grid.innerHTML = "";

    Object.entries(data).forEach(([key, src]) => {
      const card = document.createElement("div");
      card.className  = "erp-source-card";
      card.dataset.key = key;
      card.innerHTML = `
        <div class="erp-source-emoji">${src.emoji || "🏭"}</div>
        <div class="erp-source-name">${src.label}</div>
      `;
      card.addEventListener("click", () => selectErpSource(key, src, data));
      grid.appendChild(card);
    });
  } catch (e) {
    console.error("ERP kaynakları yüklenemedi:", e);
  }
}

// ── Kaynak Seç ──
function selectErpSource(key, src, allData) {
  erpSelectedKaynak   = key;
  erpSelectedDataType = null;
  erpSelectedFile     = null;

  document.querySelectorAll(".erp-source-card").forEach(c => c.classList.remove("selected"));
  document.querySelector(`.erp-source-card[data-key="${key}"]`).classList.add("selected");

  const list = document.getElementById("erpDataTypeList");
  list.innerHTML = "";
  src.veri_tipleri.forEach(vt => {
    const item = document.createElement("div");
    item.className   = "data-type-item";
    item.dataset.key = vt.key;
    item.textContent = vt.label;
    item.addEventListener("click", () => selectErpDataType(vt.key));
    list.appendChild(item);
  });

  document.getElementById("erpDataTypeCard").style.display = "block";
  document.getElementById("erpUploadCard").style.display   = "none";
  resetErpUploadState();
}

// ── Veri Türü Seç ──
function selectErpDataType(key) {
  erpSelectedDataType = key;
  document.querySelectorAll("#erpDataTypeList .data-type-item")
    .forEach(i => i.classList.remove("selected"));
  document.querySelector(`#erpDataTypeList .data-type-item[data-key="${key}"]`)
    .classList.add("selected");
  document.getElementById("erpUploadCard").style.display = "block";
  resetErpUploadState();
}

// ── Drop Zone ──
function initErpDropZone() {
  const zone      = document.getElementById("erpDropZone");
  const fileInput = document.getElementById("erpFileInput");

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
    if (file) setErpFile(file);
  });

  fileInput.addEventListener("change", () => {
    if (fileInput.files[0]) setErpFile(fileInput.files[0]);
  });
}

function setErpFile(file) {
  if (!file.name.match(/\.(xlsx|xls)$/i)) {
    showErpResult(false, "Sadece .xlsx veya .xls dosyaları kabul edilir.");
    return;
  }
  erpSelectedFile = file;
  const sfEl = document.getElementById("erpSelectedFile");
  sfEl.style.display = "flex";
  sfEl.innerHTML = `📄 <strong>${file.name}</strong> &nbsp;(${(file.size / 1024).toFixed(1)} KB)`;
  document.getElementById("erpUploadBtn").disabled = false;
  document.getElementById("erpResultBox").style.display = "none";
}

// ── Yükleme ──
async function erpUpload() {
  if (!erpSelectedFile || !erpSelectedKaynak || !erpSelectedDataType) return;

  const btn      = document.getElementById("erpUploadBtn");
  const progress = document.getElementById("erpProgressWrap");
  const result   = document.getElementById("erpResultBox");

  btn.disabled = true;
  btn.classList.add("loading");
  document.getElementById("erpUploadBtnText").textContent = "Yükleniyor...";
  progress.style.display = "flex";
  result.style.display   = "none";

  const form = new FormData();
  form.append("file",      erpSelectedFile);
  form.append("kaynak",    erpSelectedKaynak);
  form.append("data_type", erpSelectedDataType);

  try {
    const r    = await fetch(`${ERP_API}/erp/upload`, { method: "POST", body: form });
    const data = await r.json();

    progress.style.display = "none";
    btn.classList.remove("loading");
    document.getElementById("erpUploadBtnText").textContent = "Yükle";

    if (data.basarili) {
      showErpResult(true, `✅ ${data.mesaj}`);
      // Ana log panelini de güncelle
      if (typeof loadLogs === "function") loadLogs();
      // Barkod uyarısını güncelle
      erpBarkodUyariYukle();
    } else {
      showErpResult(false, `❌ ${data.hata}`);
    }
  } catch (e) {
    progress.style.display = "none";
    btn.classList.remove("loading");
    document.getElementById("erpUploadBtnText").textContent = "Yükle";
    showErpResult(false, `❌ Sunucuya ulaşılamadı: ${e.message}`);
  } finally {
    btn.disabled = false;
  }
}

function showErpResult(ok, msg) {
  const box = document.getElementById("erpResultBox");
  box.style.display = "block";
  box.className = `result-box ${ok ? "success" : "error"}`;
  box.innerHTML = msg;
}

function resetErpUploadState() {
  erpSelectedFile = null;
  document.getElementById("erpSelectedFile").style.display = "none";
  document.getElementById("erpFileInput").value = "";
  document.getElementById("erpUploadBtn").disabled = true;
  document.getElementById("erpUploadBtnText").textContent = "Yükle";
  document.getElementById("erpProgressWrap").style.display = "none";
  document.getElementById("erpResultBox").style.display = "none";
}

// ── Init ──
document.getElementById("erpUploadBtn").addEventListener("click", erpUpload);

// Uyarı toggle
document.getElementById("erpUyariToggle").addEventListener("click", () => {
  const detay  = document.getElementById("erpUyariDetay");
  const caret  = document.getElementById("erpUyariCaret");
  const açık = detay.style.display === "none";
  detay.style.display = açık ? "block" : "none";
  caret.textContent   = açık ? "▲" : "▼";
});

loadErpSources();
initErpDropZone();
erpBarkodUyariYukle();
