const API_BASE = "/api";

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

    if (btn.dataset.tab === "kategori"    && !kategoriYuklendi)  loadKategoriDesi();
    if (btn.dataset.tab === "komisyon"    && !komisyonYuklendi)  loadKomisyon(aktifKomisyonPz);
    if (btn.dataset.tab === "kullanicilar"&& !kullaniciYuklendi) loadKullanicilar();
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
    <td style="text-align:right;white-space:nowrap">
      <button class="btn-edit"   onclick="katEditBaslat(${row.id}, ${row.tahmini_desi})">Düzenle</button>
      <button class="btn-delete" onclick="katSil(${row.id})" style="margin-left:4px">Sil</button>
    </td>
  </tr>`;
}

function katYeniBaslat() {
  if (document.getElementById("kat-yeni-row")) return;
  const body = document.getElementById("kategoriBody");
  const tr = document.createElement("tr");
  tr.id = "kat-yeni-row";
  tr.className = "yeni-row";
  tr.innerHTML = `
    <td><input id="kat-yeni-ana"  placeholder="Ana Kategori *" /></td>
    <td><input id="kat-yeni-alt"  placeholder="Alt Kategori" /></td>
    <td><input id="kat-yeni-cin"  placeholder="Cinsiyet" /></td>
    <td><input id="kat-yeni-bar"  placeholder="Barkod" /></td>
    <td><input id="kat-yeni-desi" placeholder="Desi *" type="number" step="1" min="1" style="text-align:right"/></td>
    <td style="text-align:right;white-space:nowrap">
      <button class="btn-save"   onclick="katEkle()">Ekle</button>
      <button class="btn-cancel" onclick="katYeniIptal()" style="margin-left:4px">İptal</button>
    </td>`;
  body.insertBefore(tr, body.firstChild);
  document.getElementById("kat-yeni-ana").focus();
}

function katYeniIptal() {
  const tr = document.getElementById("kat-yeni-row");
  if (tr) tr.remove();
}

async function katEkle() {
  const payload = {
    ana_kategori: document.getElementById("kat-yeni-ana").value.trim(),
    alt_kategori: document.getElementById("kat-yeni-alt").value.trim(),
    cinsiyet:     document.getElementById("kat-yeni-cin").value.trim(),
    barkod:       document.getElementById("kat-yeni-bar").value.trim(),
    tahmini_desi: document.getElementById("kat-yeni-desi").value,
  };
  if (!payload.ana_kategori) { alert("Ana kategori zorunludur."); return; }
  if (!payload.tahmini_desi) { alert("Tahmini desi zorunludur."); return; }
  try {
    const r = await fetch(`${API_BASE}/ayarlar/kategori-desi`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const d = await r.json();
    if (d.basarili) { kategoriYuklendi = false; loadKategoriDesi(); }
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

async function katSil(id) {
  if (!confirm("Bu kategori desi kaydı silinecek. Emin misiniz?")) return;
  try {
    const r = await fetch(`${API_BASE}/ayarlar/kategori-desi/${id}`, { method: "DELETE" });
    const d = await r.json();
    if (d.basarili) { kategoriYuklendi = false; loadKategoriDesi(); }
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
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

// ── Komisyon Oranları ────────────────────────────────────────

const komisyonCache = new Map();
let aktifKomisyonPz = "trendyol";
let komisyonYuklendi = false;


document.querySelectorAll("#komPzSelector .pz-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    document.querySelectorAll("#komPzSelector .pz-btn").forEach(b => b.classList.remove("active"));
    btn.classList.add("active");
    aktifKomisyonPz = btn.dataset.pz;
    komisyonYuklendi = false;
    loadKomisyon(aktifKomisyonPz);
  });
});

async function loadKomisyon(pazaryeri) {
  komisyonYuklendi = true;
  const body = document.getElementById("komisyonBody");
  body.innerHTML = `<tr><td colspan="5" class="table-empty">Yükleniyor...</td></tr>`;
  komisyonCache.clear();

  try {
    const r    = await fetch(`${API_BASE}/ayarlar/komisyon-oranlari?pazaryeri=${pazaryeri}`);
    const rows = await r.json();
    if (rows.hata) {
      body.innerHTML = `<tr><td colspan="5" class="table-empty" style="color:var(--red)">${rows.hata}</td></tr>`;
      return;
    }
    if (!rows.length) {
      body.innerHTML = `<tr><td colspan="5" class="table-empty">Bu pazaryerinde kayıtlı komisyon oranı yok.</td></tr>`;
      return;
    }
    body.innerHTML = rows.map(renderKomisyonSatir).join("");
  } catch(e) {
    body.innerHTML = `<tr><td colspan="5" class="table-empty" style="color:var(--red)">Hata: ${e.message}</td></tr>`;
  }
}

function renderKomisyonSatir(row) {
  komisyonCache.set(row.id, row);
  return `<tr id="kom-row-${row.id}" data-id="${row.id}">
    <td class="kom-kategori">${row.kategori || "—"}</td>
    <td class="kom-alt">${row.alt_kategori || "—"}</td>
    <td style="text-align:right" class="mono kom-oran">%${fmt2(row.komisyon_orani)}</td>
    <td style="text-align:right;color:var(--text-muted);font-size:12px" class="kom-tarih">${row.gecerlilik_tarihi || "—"}</td>
    <td style="text-align:right;white-space:nowrap">
      <button class="btn-edit"   onclick="komEditBaslat(${row.id})">Düzenle</button>
      <button class="btn-delete" onclick="komSil(${row.id})" style="margin-left:4px">Sil</button>
    </td>
  </tr>`;
}

function komEditBaslat(id) {
  const row = komisyonCache.get(id);
  if (!row) return;
  const tr = document.getElementById(`kom-row-${id}`);

  tr.querySelector(".kom-kategori").innerHTML = `<input class="editable-input" id="kom-e-kat-${id}"  value="${row.kategori     || ""}" placeholder="Kategori"/>`;
  tr.querySelector(".kom-alt"     ).innerHTML = `<input class="editable-input" id="kom-e-alt-${id}"  value="${row.alt_kategori || ""}" placeholder="Alt Kategori"/>`;
  tr.querySelector(".kom-oran"    ).innerHTML = `<input class="editable-input" id="kom-e-oran-${id}" value="${row.komisyon_orani ?? ""}" type="number" step="0.01" style="text-align:right"/>`;
  tr.querySelector(".kom-tarih"   ).innerHTML = `<input class="editable-input" id="kom-e-tar-${id}"  value="${row.gecerlilik_tarihi || ""}" type="date"/>`;

  const editBtn = tr.querySelector(".btn-edit");
  editBtn.style.display = "none";
  editBtn.insertAdjacentHTML("afterend",
    `<button class="btn-save"   onclick="komKaydet(${id})">Kaydet</button>
     <button class="btn-cancel" onclick="loadKomisyon(aktifKomisyonPz)" style="margin-left:4px">İptal</button>`
  );
}

async function komKaydet(id) {
  const payload = {
    kategori:          document.getElementById(`kom-e-kat-${id}`).value.trim(),
    alt_kategori:      document.getElementById(`kom-e-alt-${id}`).value.trim(),
    komisyon_orani:    parseFloat(document.getElementById(`kom-e-oran-${id}`).value),
    gecerlilik_tarihi: document.getElementById(`kom-e-tar-${id}`).value || null,
  };
  try {
    const r = await fetch(`${API_BASE}/ayarlar/komisyon-oranlari/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const d = await r.json();
    if (d.basarili) { komisyonYuklendi = false; loadKomisyon(aktifKomisyonPz); }
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

async function komSil(id) {
  if (!confirm("Bu komisyon oranı kaydı silinecek. Emin misiniz?")) return;
  try {
    const r = await fetch(`${API_BASE}/ayarlar/komisyon-oranlari/${id}`, { method: "DELETE" });
    const d = await r.json();
    if (d.basarili) { komisyonYuklendi = false; loadKomisyon(aktifKomisyonPz); }
    else alert(`Hata: ${d.hata}`);
  } catch(e) { alert(`Bağlantı hatası: ${e.message}`); }
}

function komYeniBaslat() {
  if (document.getElementById("kom-yeni-row")) return;
  const body = document.getElementById("komisyonBody");
  const tr = document.createElement("tr");
  tr.id = "kom-yeni-row";
  tr.className = "yeni-row";
  tr.innerHTML = `
    <td><input id="kom-yeni-kat"  placeholder="Kategori *"/></td>
    <td><input id="kom-yeni-alt"  placeholder="Alt Kategori"/></td>
    <td><input id="kom-yeni-oran" placeholder="Oran % *" type="number" step="0.01" style="text-align:right"/></td>
    <td><input id="kom-yeni-tar"  type="date"/></td>
    <td style="text-align:right;white-space:nowrap">
      <button class="btn-save"   onclick="komEkle()">Ekle</button>
      <button class="btn-cancel" onclick="komYeniIptal()" style="margin-left:4px">İptal</button>
    </td>`;
  body.insertBefore(tr, body.firstChild);
  document.getElementById("kom-yeni-kat").focus();
}

function komYeniIptal() {
  const tr = document.getElementById("kom-yeni-row");
  if (tr) tr.remove();
}

async function komEkle() {
  const payload = {
    pazaryeri_kod:     aktifKomisyonPz,
    kategori:          document.getElementById("kom-yeni-kat").value.trim(),
    alt_kategori:      document.getElementById("kom-yeni-alt").value.trim(),
    komisyon_orani:    document.getElementById("kom-yeni-oran").value,
    gecerlilik_tarihi: document.getElementById("kom-yeni-tar").value || null,
  };
  if (!payload.kategori)       { alert("Kategori zorunludur."); return; }
  if (!payload.komisyon_orani) { alert("Komisyon oranı zorunludur."); return; }
  try {
    const r = await fetch(`${API_BASE}/ayarlar/komisyon-oranlari`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const d = await r.json();
    if (d.basarili) { komisyonYuklendi = false; loadKomisyon(aktifKomisyonPz); }
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
