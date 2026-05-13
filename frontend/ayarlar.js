const API_BASE = "http://localhost:5000/api";

const fmt2 = (n) => n == null ? "—" : new Intl.NumberFormat("tr-TR", { minimumFractionDigits:2, maximumFractionDigits:2 }).format(n);

// ── Yetki Kontrolü ──────────────────────────────────────────

document.addEventListener("DOMContentLoaded", () => {
  const kullanici = authGetUser();
  if (kullanici && kullanici.rol === "admin") {
    document.getElementById("tabKullanicilar").style.display = "";
  }
});

// ── Tab Geçişleri ────────────────────────────────────────────

document.querySelectorAll(".tab-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
    document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
    btn.classList.add("active");
    document.getElementById("panel-" + btn.dataset.tab).classList.add("active");

    if (btn.dataset.tab === "kategori" && !kategoriYuklendi) loadKategoriDesi();
    if (btn.dataset.tab === "kullanicilar" && !kullaniciYuklendi) loadKullanicilar();
  });
});

// ── Kargo Desi Fiyatları ─────────────────────────────────────

// Satır verilerini ID'ye göre saklar — onclick'e JSON gömmekten kaçınır
const kargoCache = new Map();

let aktifPazaryeri = "trendyol";

document.querySelectorAll(".pz-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".pz-btn").forEach(b => b.classList.remove("active"));
    btn.classList.add("active");
    aktifPazaryeri = btn.dataset.pz;
    loadKargoDesi(aktifPazaryeri);
  });
});

async function loadKargoDesi(pazaryeri) {
  const head = document.getElementById("kargoHead");
  const body = document.getElementById("kargoBody");
  body.innerHTML = `<tr><td colspan="15" class="table-empty">Yükleniyor...</td></tr>`;

  try {
    const r    = await fetch(`${API_BASE}/ayarlar/kargo-desi?pazaryeri=${pazaryeri}`);
    const data = await r.json();
    if (data.hata) { body.innerHTML = `<tr><td colspan="15" class="table-empty" style="color:var(--red)">${data.hata}</td></tr>`; return; }

    const { sutunlar, veriler } = data;
    const fiyatSutunlar = sutunlar.filter(s => s !== "desi" && s !== "gecerlilik_tarihi");

    head.innerHTML = `<tr>
      <th>Desi</th>
      ${fiyatSutunlar.map(s => `<th style="text-align:right">${s.replace(/_/g," ")}</th>`).join("")}
      <th style="text-align:right">Geçerlilik</th>
      <th></th>
    </tr>`;

    kargoCache.clear();
    body.innerHTML = veriler.map(row => renderKargoSatir(row, fiyatSutunlar)).join("");
  } catch(e) {
    body.innerHTML = `<tr><td colspan="15" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function renderKargoSatir(row, fiyatSutunlar) {
  kargoCache.set(row.id, { row, fiyatSutunlar });
  const gecerlilik = row.gecerlilik_tarihi
    ? String(row.gecerlilik_tarihi).substring(0, 10)
    : "—";
  return `<tr id="kargo-row-${row.id}" data-id="${row.id}">
    <td class="mono">${row.desi}</td>
    ${fiyatSutunlar.map(s => `<td style="text-align:right" class="mono kargo-val" data-col="${s}">${fmt2(row[s])}</td>`).join("")}
    <td style="text-align:right;color:var(--text-muted);font-size:12px">${gecerlilik}</td>
    <td style="text-align:right">
      <button class="btn-edit" onclick="kargoEditBaslat(${row.id})">Düzenle</button>
    </td>
  </tr>`;
}

function kargoEditBaslat(id) {
  const cached = kargoCache.get(id);
  if (!cached) return;
  const { row, fiyatSutunlar } = cached;

  const tr = document.getElementById(`kargo-row-${id}`);
  tr.querySelectorAll(".kargo-val").forEach(td => {
    const col = td.dataset.col;
    const val = row[col] != null ? row[col] : "";
    td.innerHTML = `<input class="editable-input" data-col="${col}" value="${val}" type="number" step="0.01"/>`;
  });
  const editBtn = tr.querySelector(".btn-edit");
  editBtn.style.display = "none";
  editBtn.insertAdjacentHTML("afterend",
    `<button class="btn-save"   onclick="kargoKaydet(${id})">Kaydet</button>
     <button class="btn-cancel" onclick="loadKargoDesi(aktifPazaryeri)">İptal</button>`
  );
}

async function kargoKaydet(id) {
  const tr      = document.getElementById(`kargo-row-${id}`);
  const payload = { pazaryeri: aktifPazaryeri };
  tr.querySelectorAll(".editable-input").forEach(inp => {
    payload[inp.dataset.col] = inp.value === "" ? null : parseFloat(inp.value);
  });

  try {
    const r = await fetch(`${API_BASE}/ayarlar/kargo-desi/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const d = await r.json();
    if (d.basarili) loadKargoDesi(aktifPazaryeri);
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

// ── Kategori Desi Listesi ────────────────────────────────────

let kategoriYuklendi = false;

async function loadKategoriDesi() {
  kategoriYuklendi = true;
  const body = document.getElementById("kategoriBody");
  body.innerHTML = `<tr><td colspan="6" class="table-empty">Yükleniyor...</td></tr>`;

  try {
    const r    = await fetch(`${API_BASE}/ayarlar/kategori-desi`);
    const rows = await r.json();
    if (!rows.length) {
      body.innerHTML = `<tr><td colspan="6" class="table-empty">Kayıt bulunamadı.</td></tr>`;
      return;
    }
    body.innerHTML = rows.map(renderKategoriSatir).join("");
  } catch(e) {
    body.innerHTML = `<tr><td colspan="6" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function renderKategoriSatir(row) {
  return `<tr id="kat-row-${row.id}" data-id="${row.id}">
    <td>${row.ana_kategori || "—"}</td>
    <td>${row.alt_kategori || "—"}</td>
    <td>${row.cinsiyet     || "—"}</td>
    <td class="mono">${row.barkod || "—"}</td>
    <td style="text-align:right" class="mono kat-desi">${row.tahmini_desi ?? "—"}</td>
    <td style="text-align:right">
      <button class="btn-edit" onclick="katEditBaslat(${row.id}, ${row.tahmini_desi})">Düzenle</button>
    </td>
  </tr>`;
}

function katEditBaslat(id, mevcutDesi) {
  const tr  = document.getElementById(`kat-row-${id}`);
  const td  = tr.querySelector(".kat-desi");
  td.innerHTML = `<input class="editable-input" id="kat-inp-${id}" value="${mevcutDesi ?? ""}" type="number" step="1" min="1"/>`;
  tr.querySelector(".btn-edit").style.display = "none";
  tr.querySelector("td:last-child").insertAdjacentHTML("beforeend",
    `<button class="btn-save"   onclick="katKaydet(${id})">Kaydet</button>
     <button class="btn-cancel" onclick="loadKategoriDesi()">İptal</button>`
  );
}

async function katKaydet(id) {
  const val = document.getElementById(`kat-inp-${id}`).value;
  try {
    const r = await fetch(`${API_BASE}/ayarlar/kategori-desi/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ tahmini_desi: parseInt(val) }),
    });
    const d = await r.json();
    if (d.basarili) loadKategoriDesi();
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

// ── Kullanıcı Yönetimi ───────────────────────────────────────

let kullaniciYuklendi = false;

const ROL_RENK = {
  admin:   "rol-admin",
  analist: "rol-analist",
  okuyucu: "rol-okuyucu",
};

async function loadKullanicilar() {
  kullaniciYuklendi = true;
  const body = document.getElementById("kullaniciBody");
  body.innerHTML = `<tr><td colspan="7" class="table-empty">Yükleniyor...</td></tr>`;

  try {
    const token = authGetToken();
    const r     = await fetch(`${API_BASE}/ayarlar/kullanicilar`, {
      headers: { "Authorization": `Bearer ${token}` }
    });
    if (r.status === 403) {
      body.innerHTML = `<tr><td colspan="7" class="table-empty" style="color:var(--red)">Erişim reddedildi — sadece admin görüntüleyebilir.</td></tr>`;
      return;
    }
    const rows = await r.json();
    const benimId = authGetUser()?.id;
    document.getElementById("kullaniciCount").textContent = `${rows.length} kullanıcı`;

    body.innerHTML = rows.map(u => {
      const rolClass = ROL_RENK[u.rol] || "rol-okuyucu";
      const aktifEl  = u.aktif_mi
        ? `<span class="aktif-badge aktif-evet" title="Aktif"></span>`
        : `<span class="aktif-badge aktif-hayir" title="Pasif"></span>`;
      const kendiHesabim = String(u.id) === String(benimId);

      const rolSutun = kendiHesabim
        ? `<span style="color:var(--text-muted);font-size:12px">Kendi hesabın</span>`
        : `<select class="rol-select" onchange="rolGuncelle(${u.id}, this.value)">
             <option value="okuyucu" ${u.rol==="okuyucu"?"selected":""}>Okuyucu</option>
             <option value="analist" ${u.rol==="analist"?"selected":""}>Analist</option>
             <option value="admin"   ${u.rol==="admin"  ?"selected":""}>Admin</option>
           </select>`;

      return `<tr id="usr-row-${u.id}" ${kendiHesabim ? 'style="opacity:0.7"' : ""}>
        <td><strong>${u.ad} ${u.soyad}</strong></td>
        <td style="color:var(--text-muted)">${u.email}</td>
        <td><span class="rol-badge ${rolClass}">${u.rol}</span></td>
        <td style="text-align:center">${aktifEl}</td>
        <td style="color:var(--text-muted);font-size:12px">${u.son_giris || "—"}</td>
        <td style="color:var(--text-muted);font-size:12px">${u.olusturma_tarihi || "—"}</td>
        <td>${rolSutun}</td>
      </tr>`;
    }).join("");
  } catch(e) {
    body.innerHTML = `<tr><td colspan="7" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

async function rolGuncelle(userId, yeniRol) {
  try {
    const token = authGetToken();
    const r = await fetch(`${API_BASE}/ayarlar/kullanicilar/${userId}/rol`, {
      method: "PUT",
      headers: { "Content-Type": "application/json", "Authorization": `Bearer ${token}` },
      body: JSON.stringify({ rol: yeniRol }),
    });
    const d = await r.json();
    if (d.basarili) {
      kullaniciYuklendi = false;
      loadKullanicilar();
    } else {
      alert(`Hata: ${d.hata}`);
    }
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

// ── İlk Yükleme ─────────────────────────────────────────────
loadKargoDesi("trendyol");
