const API_BASE = "/api";

const DURUM_CONFIG = {
  eslesdi:         { label: "Eşleşti",         badge: "badge-green"  },
  fark_var:        { label: "Fark Var",         badge: "badge-yellow" },
  manuel_inceleme: { label: "Manuel İnceleme",  badge: "badge-red"    },
  beklemede:       { label: "Beklemede",        badge: "badge-muted"  },
};

const fmt  = (n) => new Intl.NumberFormat("tr-TR", { minimumFractionDigits:2, maximumFractionDigits:2 }).format(n || 0);
const fmtF = (n) => {
  const v = parseFloat(n) || 0;
  const s = fmt(Math.abs(v));
  if (v < 0) return `<span style="color:var(--red)">-${s} ₺</span>`;
  if (v > 0) return `<span style="color:var(--yellow)">+${s} ₺</span>`;
  return `<span style="color:var(--text-muted)">0,00 ₺</span>`;
};

const LIMIT = 10;
let suankiSayfa = 1;

// ── Özet Kartları ──
async function loadMutabakatOzet() {
  try {
    const r = await fetch(`${API_BASE}/mutabakat/ozet`);
    const rows = await r.json();

    let eslesen = 0, fark = 0, beklemede = 0;
    rows.forEach(r => {
      if (r.mutabakat_durumu === "eslesdi")  eslesen   += r.adet;
      if (r.mutabakat_durumu === "fark_var") fark      += r.adet;
      if (r.mutabakat_durumu === "beklemede") beklemede += r.adet;
    });

    document.getElementById("statEslesen").textContent   = eslesen;
    document.getElementById("statFark").textContent      = fark;
    document.getElementById("statBeklemede").textContent = beklemede;
  } catch(e) {
    console.error("Özet yüklenemedi:", e);
  }
}

// ── Tam Liste ──
async function loadMutabakatListe(sayfa = 1) {
  suankiSayfa = sayfa;
  const pazaryeri = document.getElementById("filtPazaryeri").value;
  const durum     = document.getElementById("filtDurum").value;

  const params = new URLSearchParams({ sayfa, limit: LIMIT });
  if (pazaryeri) params.append("pazaryeri", pazaryeri);
  if (durum)     params.append("durum",     durum);

  const body = document.getElementById("mutabakatBody");
  body.innerHTML = `<tr><td colspan="19" class="table-empty">Yükleniyor...</td></tr>`;

  try {
    const r    = await fetch(`${API_BASE}/mutabakat/liste?${params}`);
    const data = await r.json();

    document.getElementById("mutabakatCount").textContent =
      `${data.toplam.toLocaleString("tr-TR")} kayıt`;

    if (!data.veriler.length) {
      body.innerHTML = `<tr><td colspan="19" class="table-empty">Sonuç bulunamadı.</td></tr>`;
      document.getElementById("mutabakatPagination").innerHTML = "";
      return;
    }

    body.innerHTML = data.veriler.map(row => {
      const cfg  = DURUM_CONFIG[row.mutabakat_durumu] || { label: row.mutabakat_durumu, badge: "badge-muted" };
      const fark = row.fark_var_mi ? `<span class="badge badge-yellow">⚠ Fark</span>` : "";
      const muk  = row.mukrerrer_mi ? `<span class="badge badge-red">⊗ Mükerrer</span>` : "";
      return `
        <tr>
          <td class="mono">${row.siparis_no       || "—"}</td>
          <td class="mono">${row.pazaryeri_siparis_no || "—"}</td>
          <td>${row.pazaryeri}</td>
          <td class="mono">${row.barkod           || "—"}</td>
          <td class="urun-adi" title="${row.urun_adi || ""}">${row.urun_adi || "—"}</td>
          <td>${row.siparis_tarihi                || "—"}</td>
          <td>${row.siparis_durumu                || "—"}</td>
          <td><span class="badge ${cfg.badge}">${cfg.label}</span></td>
          <td style="text-align:right">${fmt(row.beklenen_odeme)} ₺</td>
          <td style="text-align:right">${fmt(row.gerceklesen_odeme)} ₺</td>
          <td style="text-align:right">${fmtF(row.odeme_farki)}</td>
          <td style="text-align:right">${fmt(row.beklenen_komisyon)} ₺</td>
          <td style="text-align:right">${fmt(row.faturalanan_komisyon)} ₺</td>
          <td style="text-align:right">${fmtF(row.komisyon_farki)}</td>
          <td style="text-align:right">${fmt(row.beklenen_kargo)} ₺</td>
          <td style="text-align:right">${fmt(row.faturalanan_satis_kargosu)} ₺</td>
          <td style="text-align:right">${fmtF(row.kargo_farki)}</td>
          <td>${fark}</td>
          <td>${muk}</td>
        </tr>`;
    }).join("");

    renderMutabakatPagination(data.toplam, sayfa);

  } catch(e) {
    body.innerHTML = `<tr><td colspan="19" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function renderMutabakatPagination(toplam, current) {
  const totalPages = Math.ceil(toplam / LIMIT);
  const el = document.getElementById("mutabakatPagination");
  if (totalPages <= 1) { el.innerHTML = ""; return; }

  const pages = [];
  if (totalPages <= 7) {
    for (let i = 1; i <= totalPages; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push("…");
    for (let i = Math.max(2, current - 1); i <= Math.min(totalPages - 1, current + 1); i++) pages.push(i);
    if (current < totalPages - 2) pages.push("…");
    pages.push(totalPages);
  }

  el.innerHTML = pages.map(p =>
    p === "…"
      ? `<span class="page-ellipsis">…</span>`
      : `<button type="button" class="page-btn${p === current ? " active" : ""}" onclick="loadMutabakatListe(${p})">${p}</button>`
  ).join("");
}

// ── Event Listeners ──
document.getElementById("filtBtn").addEventListener("click", () => loadMutabakatListe(1));

document.getElementById("mutabakatYapBtn").addEventListener("click", async () => {
  const btn = document.getElementById("mutabakatYapBtn");
  btn.disabled = true;
  btn.textContent = "⏳ İşleniyor...";

  try {
    const r    = await fetch(`${API_BASE}/mutabakat/hesapla`, { method: "POST" });
    const data = await r.json();

    if (data.basarili) {
      const o = data.ozet;
      let mesaj = `Mutabakat tamamlandı!\n\nToplam  : ${o.toplam}\nEşleşti : ${o.eslesdi}\nFark Var: ${o.fark_var}`;
      if (o.hata_sayisi > 0) {
        mesaj += `\n\nHatalı  : ${o.hata_sayisi}`;
        if (o.hatalar && o.hatalar.length) mesaj += `\n${o.hatalar.join("\n")}`;
      }
      alert(mesaj);
      loadMutabakatOzet();
      loadMutabakatListe(1);
      loadDesiOzet();
      loadDesiPazaryeri();
      loadDesiDetay();
    } else {
      alert(`Hata: ${data.hata}`);
    }
  } catch (e) {
    alert(`Bağlantı hatası: ${e.message}`);
  } finally {
    btn.disabled = false;
    btn.textContent = "⚡ Mutabakat Yap";
  }
});

// ── Kargo Desi Mutabakatı ──

const fmtDesi = (n) => (n ?? 0).toLocaleString("tr-TR", { minimumFractionDigits: 0, maximumFractionDigits: 1 });
const fmtKargo = (n) => (n ?? 0).toLocaleString("tr-TR", { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + " ₺";
const MP_EMOJIS = { Trendyol:"🛍️", Hepsiburada:"🔶", Amazon:"📦", N11:"🟠", Pazarama:"🟣", Flo:"👟", LCW:"👕" };

let desiSayfa = 1;
let desiFilters = {};

async function loadDesiOzet(filters = {}) {
  try {
    const r = await fetch(`${API_BASE}/kargo-desi/ozet?${new URLSearchParams(filters)}`);
    const d = await r.json();

    document.getElementById("desiStatToplam").textContent    = Math.round(d.toplam ?? 0).toLocaleString("tr-TR");
    document.getElementById("desiStatEslesen").textContent   = Math.round(d.eslesen ?? 0).toLocaleString("tr-TR");
    document.getElementById("desiStatAleyhimize").textContent= Math.round(d.aleyhimize ?? 0).toLocaleString("tr-TR");
    document.getElementById("desiStatLehimize").textContent  = Math.round(d.lehimize ?? 0).toLocaleString("tr-TR");
    document.getElementById("desiStatOrtFat").textContent    = fmtDesi(d.ort_faturalanan_desi);
    document.getElementById("desiStatOrtTah").textContent    = fmtDesi(d.ort_tahmini_desi);

    const fark = d.toplam_desi_farki ?? 0;
    const el   = document.getElementById("desiStatToplamFark");
    el.textContent = (fark > 0 ? "+" : "") + fmtDesi(fark);
    el.style.color = fark > 0 ? "var(--red)" : fark < 0 ? "var(--green)" : "var(--text)";
  } catch(e) { console.error("Desi özet:", e); }
}

async function loadDesiPazaryeri() {
  const tbody = document.getElementById("desiPazaryeriBody");
  try {
    const r = await fetch(`${API_BASE}/kargo-desi/pazaryeri`);
    const rows = await r.json();

    if (!rows.length) {
      tbody.innerHTML = `<tr><td colspan="9" class="table-empty">Veri yok — önce Mutabakat Yap çalıştırın.</td></tr>`;
      return;
    }

    tbody.innerHTML = rows.map(row => {
      const fark = row.toplam_desi_farki ?? 0;
      const farkCss = fark > 0 ? "color:var(--red);font-weight:600"
                    : fark < 0 ? "color:var(--green);font-weight:600" : "";
      return `
        <tr>
          <td><strong>${MP_EMOJIS[row.pazaryeri] || "🏪"} ${row.pazaryeri}</strong></td>
          <td style="text-align:center">${Math.round(row.toplam ?? 0).toLocaleString("tr-TR")}</td>
          <td style="text-align:center;color:var(--green)">${Math.round(row.eslesen ?? 0).toLocaleString("tr-TR")}</td>
          <td style="text-align:center;color:var(--yellow)">${Math.round(row.farkli ?? 0).toLocaleString("tr-TR")}</td>
          <td style="text-align:center;color:var(--red)">${Math.round(row.aleyhimize ?? 0).toLocaleString("tr-TR")}</td>
          <td style="text-align:center;color:var(--accent)">${Math.round(row.lehimize ?? 0).toLocaleString("tr-TR")}</td>
          <td style="text-align:right;${farkCss}">${fark > 0 ? "+" : ""}${fmtDesi(fark)}</td>
          <td style="text-align:right">${fmtDesi(row.ort_faturalanan_desi)}</td>
          <td style="text-align:right">${fmtDesi(row.ort_tahmini_desi)}</td>
        </tr>`;
    }).join("");
  } catch(e) {
    tbody.innerHTML = `<tr><td colspan="9" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

async function loadDesiDetay(filters = {}, sayfa = 1) {
  desiSayfa = sayfa;
  const params = new URLSearchParams({ ...filters, sayfa, limit: 10 });
  const body   = document.getElementById("desiDetayBody");
  body.innerHTML = `<tr><td colspan="11" class="table-empty">Yükleniyor...</td></tr>`;

  try {
    const r = await fetch(`${API_BASE}/kargo-desi/liste?${params}`);
    const d = await r.json();

    document.getElementById("desiDetayCount").textContent =
      `${Math.round(d.toplam ?? 0).toLocaleString("tr-TR")} kayıt`;

    if (!d.veriler || !d.veriler.length) {
      body.innerHTML = `<tr><td colspan="11" class="table-empty">Veri bulunamadı.</td></tr>`;
      document.getElementById("desiDetayPagination").innerHTML = "";
      return;
    }

    body.innerHTML = d.veriler.map(row => {
      const fark     = row.desi_farki ?? 0;
      const farkText = fark === 0 ? "0" : (fark > 0 ? `+${Math.round(fark)}` : `${Math.round(fark)}`);
      const farkCss  = fark > 0 ? "color:var(--red);font-weight:600"
                     : fark < 0 ? "color:var(--green);font-weight:600" : "color:var(--text-muted)";
      const badge    = fark === 0
        ? `<span class="badge badge-green">Eşleşti</span>`
        : fark > 0
          ? `<span class="badge badge-red">Aleyhimize</span>`
          : `<span class="badge badge-muted">Lehimize</span>`;
      const urunAdi  = (row.urun_adi || "").length > 26
        ? row.urun_adi.substring(0, 26) + "…" : (row.urun_adi || "—");

      return `
        <tr>
          <td class="mono">${row.siparis_no || "—"}</td>
          <td class="mono">${row.pazaryeri_siparis_no || "—"}</td>
          <td>${MP_EMOJIS[row.pazaryeri] || ""} ${row.pazaryeri || "—"}</td>
          <td class="mono">${row.barkod || "—"}</td>
          <td class="urun-adi" title="${row.urun_adi || ""}">${urunAdi}</td>
          <td>${row.siparis_tarihi || "—"}</td>
          <td style="text-align:center;font-weight:600">${Math.round(row.tahmini_desi ?? 0)}</td>
          <td style="text-align:center;font-weight:600">${Math.round(row.faturalanan_desi ?? 0)}</td>
          <td style="text-align:center;${farkCss}">${farkText}</td>
          <td style="text-align:right">${fmtKargo(row.satis_kargosu)}</td>
          <td>${badge}</td>
        </tr>`;
    }).join("");

    renderDesiPagination(d.toplam, sayfa);
  } catch(e) {
    body.innerHTML = `<tr><td colspan="11" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function renderDesiPagination(toplam, current) {
  const totalPages = Math.ceil(toplam / 10);
  const el = document.getElementById("desiDetayPagination");
  if (totalPages <= 1) { el.innerHTML = ""; return; }

  const pages = [];
  if (totalPages <= 7) {
    for (let i = 1; i <= totalPages; i++) pages.push(i);
  } else {
    pages.push(1);
    if (current > 3) pages.push("…");
    for (let i = Math.max(2, current-1); i <= Math.min(totalPages-1, current+1); i++) pages.push(i);
    if (current < totalPages - 2) pages.push("…");
    pages.push(totalPages);
  }

  el.innerHTML = pages.map(p =>
    p === "…"
      ? `<span class="page-ellipsis">…</span>`
      : `<button type="button" class="page-btn${p === current ? " active" : ""}" onclick="loadDesiDetay(desiFilters,${p})">${p}</button>`
  ).join("");
}

document.getElementById("desiFiltBtn").addEventListener("click", () => {
  desiFilters = {
    pazaryeri: document.getElementById("desiFiltPazaryeri").value,
    durum:     document.getElementById("desiFiltDurum").value,
  };
  Object.keys(desiFilters).forEach(k => { if (!desiFilters[k]) delete desiFilters[k]; });
  loadDesiOzet(desiFilters);
  loadDesiDetay(desiFilters, 1);
});

document.getElementById("desiToggle").addEventListener("click", () => {
  const icerik = document.getElementById("desiIcerik");
  const toggle = document.getElementById("desiToggle");
  const gizli  = icerik.style.display === "none";
  icerik.style.display = gizli ? "block" : "none";
  toggle.textContent   = gizli ? "▼ Gizle" : "▶ Göster";
});

// ── Init ──
loadMutabakatOzet();
loadMutabakatListe(1);
loadDesiOzet();
loadDesiPazaryeri();
loadDesiDetay();
