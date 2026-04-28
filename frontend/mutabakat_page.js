const API_BASE = "http://localhost:5000/api";

const DURUM_CONFIG = {
  eslesdi:         { label: "Eslesti",         badge: "badge-green" },
  fark_var:        { label: "Fark Var",        badge: "badge-yellow" },
  manuel_inceleme: { label: "Manuel Inceleme", badge: "badge-red" },
  beklemede:       { label: "Beklemede",       badge: "badge-muted" },
};

const fmt = (n) => new Intl.NumberFormat("tr-TR", { minimumFractionDigits:2, maximumFractionDigits:2 }).format(n || 0);

async function loadMutabakatOzet() {
  try {
    const r = await fetch(`${API_BASE}/mutabakat/ozet`);
    const rows = await r.json();

    // Stat kartlarını hesapla
    let eslesen=0, fark=0, manuel=0, beklemede=0;
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

    // Tablo
    const body = document.getElementById("mutabakatBody");
    if (!rows.length) {
      body.innerHTML = `<tr><td colspan="4" class="table-empty">Henüz mutabakat verisi yok.</td></tr>`;
      return;
    }

    body.innerHTML = rows.map(row => {
      const cfg = DURUM_CONFIG[row.mutabakat_durumu] || { label: row.mutabakat_durumu, badge: "badge-muted" };
      const farkColor = row.toplam_fark < 0 ? "color:var(--red)" : row.toplam_fark > 0 ? "color:var(--yellow)" : "";
      return `
        <tr>
          <td>${row.pazaryeri}</td>
          <td><span class="badge ${cfg.badge}">${cfg.label}</span></td>
          <td style="text-align:center">${row.adet}</td>
          <td style="${farkColor};font-weight:600">${fmt(row.toplam_fark)} ₺</td>
        </tr>`;
    }).join("");

  } catch(e) {
    document.getElementById("mutabakatBody").innerHTML =
      `<tr><td colspan="4" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

loadMutabakatOzet();
