const API_BASE = "http://localhost:5000/api";

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

let suankiSayfa = 1;

// ── Özet Kartları ──
async function loadMutabakatOzet() {
  try {
    const r = await fetch(`${API_BASE}/mutabakat/ozet`);
    const rows = await r.json();

    let eslesen = 0, fark = 0, manuel = 0, beklemede = 0;
    rows.forEach(r => {
      if (r.mutabakat_durumu === "eslesdi")         eslesen   += r.adet;
      if (r.mutabakat_durumu === "fark_var")        fark      += r.adet;
      if (r.mutabakat_durumu === "manuel_inceleme") manuel    += r.adet;
      if (r.mutabakat_durumu === "beklemede")       beklemede += r.adet;
    });

    document.getElementById("statEslesen").textContent   = eslesen;
    document.getElementById("statFark").textContent      = fark;
    document.getElementById("statManuel").textContent    = manuel;
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
  const limit     = document.getElementById("filtLimit").value;

  const params = new URLSearchParams({ sayfa, limit });
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
      document.getElementById("mutabakatPagination").style.display = "none";
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

    // Sayfalama
    const toplamSayfa = Math.ceil(data.toplam / limit);
    const pag = document.getElementById("mutabakatPagination");
    pag.style.display = toplamSayfa > 1 ? "flex" : "none";
    document.getElementById("pageInfo").textContent = `Sayfa ${sayfa} / ${toplamSayfa}`;
    document.getElementById("prevBtn").disabled = sayfa <= 1;
    document.getElementById("nextBtn").disabled = sayfa >= toplamSayfa;

  } catch(e) {
    body.innerHTML = `<tr><td colspan="19" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

// ── Event Listeners ──
document.getElementById("filtBtn").addEventListener("click", () => loadMutabakatListe(1));

document.getElementById("prevBtn").addEventListener("click", () => {
  if (suankiSayfa > 1) loadMutabakatListe(suankiSayfa - 1);
});
document.getElementById("nextBtn").addEventListener("click", () => {
  loadMutabakatListe(suankiSayfa + 1);
});

// ── Init ──
loadMutabakatOzet();
loadMutabakatListe(1);
