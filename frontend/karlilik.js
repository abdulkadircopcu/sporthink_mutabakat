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
      body.innerHTML = `<tr><td colspan="13" class="table-empty">Veri bulunamadi.</td></tr>`;
      renderPagination(0, sayfa);
      return;
    }

    body.innerHTML = d.veriler.map(row => {
      const isZarar = row.zarar_mi == 1;
      const marjColor = isZarar ? "color:var(--red)" : "color:var(--green)";
      const durumBadge = isZarar
        ? `<span class="badge badge-red">Zarar</span>`
        : `<span class="badge badge-green">Karli</span>`;
      const mutBadge = row.mutabakat_durumu
        ? `<span class="badge badge-${mutabakatRenk(row.mutabakat_durumu)}">${row.mutabakat_durumu}</span>`
        : "";
      return `
        <tr class="${isZarar ? "row-zarar" : ""}">
          <td>${row.siparis_tarihi || "—"}</td>
          <td>${MP_EMOJIS[row.pazaryeri] || ""} ${row.pazaryeri}</td>
          <td class="mono">${row.pazaryeri_siparis_no || row.siparis_no}</td>
          <td class="urun-adi" title="${row.urun_adi || ""}">${truncate(row.urun_adi, 30)}</td>
          <td style="text-align:center">${row.satis_adeti ?? "—"}</td>
          <td>${fmtCur(row.satis_tutari)}</td>
          <td>${fmtCur(row.urun_maliyeti)}</td>
          <td>${fmtCur(row.komisyon)}</td>
          <td>${fmtCur(row.kargo)}</td>
          <td>${fmtCur(row.net_gelir)}</td>
          <td style="${marjColor};font-weight:600">${fmtCur(row.net_kar)}</td>
          <td style="${marjColor}">${fmt(row.kar_marji)}%</td>
          <td>${durumBadge}</td>
        </tr>`;
    }).join("");

    renderPagination(d.toplam, sayfa);
  } catch(e) {
    body.innerHTML = `<tr><td colspan="13" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
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
    baslangic: document.getElementById("filterBaslangic").value,
    bitis:     document.getElementById("filterBitis").value,
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
