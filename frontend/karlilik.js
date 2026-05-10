const API_BASE = "http://localhost:5000/api";
const MP_EMOJIS = { Trendyol:"🛍️", Hepsiburada:"🔶", Amazon:"📦", N11:"🟠", Pazarama:"🟣", Flo:"👟", LCW:"👕" };

let currentPage = 1;
let currentFilters = {};

const fmt = (n) => new Intl.NumberFormat("tr-TR", { minimumFractionDigits:2, maximumFractionDigits:2 }).format(n || 0);
const fmtCur = (n) => fmt(n) + " ₺";

async function loadOzet(filters = {}) {
  const params = new URLSearchParams(filters).toString();
  try {
    const r = await fetch(`${API_BASE}/karlilik/ozet?${params}`);
    const d = await r.json();
    document.getElementById("statSiparis").textContent = d.toplam_siparis ?? "—";
    document.getElementById("statCiro").textContent    = fmtCur(d.toplam_ciro);
    document.getElementById("statKar").textContent     = fmtCur(d.toplam_kar);
    document.getElementById("statMarj").textContent    = fmt(d.ort_kar_marji) + "%";
    document.getElementById("statZarar").textContent   = d.zarar_siparis ?? "—";

    const karEl = document.getElementById("statKar");
    karEl.style.color = d.toplam_kar >= 0 ? "var(--green)" : "var(--red)";
  } catch(e) {
    console.error("Özet yüklenemedi:", e);
  }
}

async function loadListe(filters = {}, sayfa = 1) {
  const params = new URLSearchParams({ ...filters, sayfa, limit: 50 }).toString();
  const body = document.getElementById("karlilikBody");
  body.innerHTML = `<tr><td colspan="13" class="table-empty">Yukleniyor...</td></tr>`;

  try {
    const r = await fetch(`${API_BASE}/karlilik/liste?${params}`);
    const d = await r.json();

    document.getElementById("tableCount").textContent = `Toplam: ${d.toplam} siparis`;

    if (!d.veriler || d.veriler.length === 0) {
      body.innerHTML = `<tr><td colspan="12" class="table-empty">Veri bulunamadi.</td></tr>`;
      renderPagination(0, sayfa);
      return;
    }

    body.innerHTML = d.veriler.map(row => {
      const netKar      = row.net_kar;
      const maliyet     = row.urun_maliyeti;
      const hesaplandi  = maliyet !== null && maliyet !== 0 && netKar !== null;
      const isZarar     = hesaplandi && netKar < 0;
      const isKarli     = hesaplandi && netKar >= 0;
      const marjColor   = isZarar ? "color:var(--red)" : isKarli ? "color:var(--green)" : "color:var(--muted,#888)";

      const durumBadge = !hesaplandi
        ? `<span class="badge badge-muted">Hesaplanmadı</span>`
        : isZarar
          ? `<span class="badge badge-red">Zarar</span>`
          : `<span class="badge badge-green">Karlı</span>`;

      const mutBadge = row.mutabakat_durumu
        ? `<span class="badge badge-${mutabakatRenk(row.mutabakat_durumu)}">${row.mutabakat_durumu}</span>`
        : "";
      return `
        <tr class="${isZarar ? "row-zarar" : ""}">
          <td>${row.siparis_tarihi || "—"}</td>
          <td>${MP_EMOJIS[row.pazaryeri] || ""} ${row.pazaryeri}</td>
          <td class="mono">${row.pazaryeri_siparis_no || row.siparis_no}</td>
          <td class="urun-adi" title="${row.urun_adi || ""}">${truncate(row.urun_adi, 30)}</td>
          <td>${fmtCur(row.satis_tutari)}</td>
          <td>${maliyet ? fmtCur(maliyet) : '<span style="color:#888">—</span>'}</td>
          <td>${fmtCur(row.komisyon)}</td>
          <td>${fmtCur(row.kargo)}</td>
          <td>${fmtCur(row.net_gelir)}</td>
          <td style="${marjColor};font-weight:600">${hesaplandi ? fmtCur(netKar) : '<span style="color:#888">—</span>'}</td>
          <td style="${marjColor}">${hesaplandi ? fmt(row.kar_marji)+"%" : "—"}</td>
          <td>${durumBadge}</td>
        </tr>`;
    }).join("");

    renderPagination(d.toplam, sayfa);
  } catch(e) {
    body.innerHTML = `<tr><td colspan="12" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function mutabakatRenk(d) {
  return { eslesdi:"green", fark_var:"yellow", manuel_inceleme:"red", beklemede:"muted" }[d] || "muted";
}

function truncate(str, len) {
  if (!str) return "—";
  return str.length > len ? str.substring(0, len) + "…" : str;
}

function renderPagination(toplam, current) {
  const totalPages = Math.ceil(toplam / 50);
  const el = document.getElementById("pagination");
  if (totalPages <= 1) { el.innerHTML = ""; return; }

  let html = "";
  if (current > 1)      html += `<button class="page-btn" onclick="goPage(${current-1})">← Onceki</button>`;
  html += `<span class="page-info">${current} / ${totalPages}</span>`;
  if (current < totalPages) html += `<button class="page-btn" onclick="goPage(${current+1})">Sonraki →</button>`;
  el.innerHTML = html;
}

function goPage(p) {
  currentPage = p;
  loadListe(currentFilters, p);
  window.scrollTo({ top: 0, behavior:"smooth" });
}

function getFilters() {
  return {
    pazaryeri: document.getElementById("filterPazaryeri").value,
    durum:     document.getElementById("filterDurum").value,
  };
}

document.getElementById("filterBtn").addEventListener("click", () => {
  currentFilters = getFilters();
  currentPage    = 1;
  loadOzet(currentFilters);
  loadListe(currentFilters, 1);
});

// İlk yükleme
loadOzet();
loadListe();
loadKarsilastirma();


// ── Pazaryeri Karşılaştırma ──
let karsData     = [];
let karsMetric   = "toplam_ciro";

const METRIC_LABELS = {
  toplam_ciro:     { label: "Ciro",        suffix: " ₺", fmt: (v) => fmt(v) + " ₺" },
  toplam_kar:      { label: "Net Kâr",     suffix: " ₺", fmt: (v) => fmt(v) + " ₺" },
  ort_kar_marji:   { label: "Kâr Marjı",   suffix: "%",  fmt: (v) => fmt(v) + "%" },
  siparis_sayisi:  { label: "Sipariş",     suffix: "",   fmt: (v) => Math.round(v).toLocaleString("tr-TR") },
  toplam_komisyon: { label: "Komisyon",    suffix: " ₺", fmt: (v) => fmt(v) + " ₺" },
  toplam_kargo:    { label: "Kargo",       suffix: " ₺", fmt: (v) => fmt(v) + " ₺" },
};

async function loadKarsilastirma() {
  try {
    const r = await fetch(`${API_BASE}/karlilik/pazaryeri-karsilastirma`);
    karsData = await r.json();
    renderKarsListe();
    renderKarsTable();
  } catch(e) {
    document.getElementById("karsilastirmaListe").innerHTML =
      `<div class="table-empty" style="color:var(--red)">Hata: ${e.message}</div>`;
  }
}

function renderKarsListe() {
  const liste   = document.getElementById("karsilastirmaListe");
  const mCfg    = METRIC_LABELS[karsMetric];
  const values  = karsData.map(r => parseFloat(r[karsMetric]) || 0);
  const maxVal  = Math.max(...values, 1);

  liste.innerHTML = karsData.map((row, i) => {
    const val     = values[i];
    const pct     = Math.max((val / maxVal) * 100, 0).toFixed(1);
    const isNeg   = val < 0;
    const barColor = karsMetric === "toplam_kar"
      ? (isNeg ? "var(--red)" : "var(--green)")
      : "var(--accent)";

    return `
      <div class="kars-row">
        <div class="kars-label">
          <span class="kars-emoji">${MP_EMOJIS[row.pazaryeri] || "🏪"}</span>
          <span class="kars-mp-name">${row.pazaryeri}</span>
        </div>
        <div class="kars-bar-wrap">
          <div class="kars-bar" style="width:${Math.abs(pct)}%;background:${barColor};"></div>
        </div>
        <div class="kars-value" style="color:${isNeg ? "var(--red)" : "var(--text)"}">
          ${mCfg.fmt(val)}
        </div>
        <div class="kars-share">${pct}%</div>
      </div>`;
  }).join("");
}

function renderKarsTable() {
  const tbody = document.getElementById("karsBody");
  if (!karsData.length) {
    tbody.innerHTML = `<tr><td colspan="10" class="table-empty">Veri yok</td></tr>`;
    return;
  }
  tbody.innerHTML = karsData.map(row => {
    const marjColor = row.ort_kar_marji < 0 ? "color:var(--red)"
                    : row.ort_kar_marji > 10 ? "color:var(--green)" : "";
    const karColor  = row.toplam_kar < 0 ? "color:var(--red);font-weight:600" : "color:var(--green);font-weight:600";
    return `
      <tr>
        <td><strong>${MP_EMOJIS[row.pazaryeri] || "🏪"} ${row.pazaryeri}</strong></td>
        <td style="text-align:center">${Math.round(row.siparis_sayisi).toLocaleString("tr-TR")}</td>
        <td style="text-align:right">${fmt(row.toplam_ciro)} ₺</td>
        <td style="text-align:right;${karColor}">${fmt(row.toplam_kar)} ₺</td>
        <td style="text-align:right;${marjColor}">${fmt(row.ort_kar_marji)}%</td>
        <td style="text-align:right">${fmt(row.ort_siparis_tutari)} ₺</td>
        <td style="text-align:right;color:var(--yellow)">${fmt(row.toplam_komisyon)} ₺</td>
        <td style="text-align:right;color:var(--text-muted)">${fmt(row.toplam_kargo)} ₺</td>
        <td style="text-align:center;color:var(--green)">${Math.round(row.karli_sayisi).toLocaleString("tr-TR")}</td>
        <td style="text-align:center;color:var(--red)">${Math.round(row.zarar_sayisi).toLocaleString("tr-TR")}</td>
      </tr>`;
  }).join("");
}

// Tab geçişleri
document.getElementById("karsTabs").addEventListener("click", (e) => {
  const btn = e.target.closest(".kars-tab");
  if (!btn) return;
  document.querySelectorAll(".kars-tab").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  karsMetric = btn.dataset.metric;
  renderKarsListe();
});

// Gizle/Göster toggle
document.getElementById("karsilastirmaToggle").addEventListener("click", () => {
  const icerik = document.getElementById("karsilastirmaIcerik");
  const toggle = document.getElementById("karsilastirmaToggle");
  const gizli  = icerik.style.display === "none";
  icerik.style.display = gizli ? "block" : "none";
  toggle.textContent   = gizli ? "▼ Gizle" : "▶ Göster";
});
