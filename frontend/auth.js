/**
 * auth.js — Tüm korumalı sayfalara eklenir.
 * Token kontrolü yapar, geçersizse login'e yönlendirir.
 * Nav'a kullanıcı adı ve çıkış butonu ekler.
 */

const AUTH_API = "http://localhost:5000/api";

function authGetToken() {
  return localStorage.getItem("auth_token");
}

function authGetUser() {
  try {
    return JSON.parse(localStorage.getItem("auth_kullanici")) || null;
  } catch { return null; }
}

function authLogout() {
  localStorage.removeItem("auth_token");
  localStorage.removeItem("auth_kullanici");
  window.location.replace("/login.html");
}

// Sayfa yüklendiğinde token doğrula
async function authKontrol() {
  const token = authGetToken();
  if (!token) {
    window.location.replace("/login.html");
    return;
  }

  try {
    const r = await fetch(`${AUTH_API}/auth/me`, {
      headers: { "Authorization": `Bearer ${token}` }
    });
    if (!r.ok) {
      authLogout();
      return;
    }
    const data = await r.json();
    if (!data.basarili) {
      authLogout();
      return;
    }
    // Kullanıcı bilgisini güncelle (token yenilenmedi ama veri taze)
    localStorage.setItem("auth_kullanici", JSON.stringify(data.kullanici));
    authNavKullanici(data.kullanici);
  } catch {
    // Sunucu erişilemez — localStorage'dan devam et
    const user = authGetUser();
    if (user) authNavKullanici(user);
    else authLogout();
  }
}

// Nav'a kullanıcı chip + çıkış butonu ekle
function authNavKullanici(kullanici) {
  const nav = document.getElementById("mainNav");
  if (!nav) return;

  // Zaten eklendiyse tekrar ekleme
  if (document.getElementById("authUserChip")) return;

  const ROL_BADGE = {
    admin:   { label: "Admin",   color: "#a371f7" },
    analist: { label: "Analist", color: "#58a6ff" },
    okuyucu: { label: "Okuyucu", color: "#8b949e" },
  };
  const rolCfg = ROL_BADGE[kullanici.rol] || ROL_BADGE.okuyucu;

  const chip = document.createElement("div");
  chip.id = "authUserChip";
  chip.style.cssText = `
    display:flex; align-items:center; gap:10px; margin-left:16px;
    padding:5px 12px 5px 10px; background:rgba(255,255,255,0.04);
    border:1px solid #30363d; border-radius:20px;
  `;
  chip.innerHTML = `
    <div style="text-align:right;">
      <div style="font-size:12px;font-weight:600;color:#e6edf3;">${kullanici.ad} ${kullanici.soyad}</div>
      <div style="font-size:10px;font-weight:700;color:${rolCfg.color};text-transform:uppercase;letter-spacing:0.06em;">${rolCfg.label}</div>
    </div>
    <button id="authLogoutBtn" title="Çıkış Yap" style="
      background:none; border:none; color:#8b949e; cursor:pointer;
      font-size:16px; padding:2px 4px; border-radius:4px;
      transition:color 0.15s; line-height:1;
    ">⏻</button>
  `;
  nav.after(chip);

  document.getElementById("authLogoutBtn").addEventListener("click", authLogout);
  document.getElementById("authLogoutBtn").addEventListener("mouseenter", (e) => {
    e.target.style.color = "#f85149";
  });
  document.getElementById("authLogoutBtn").addEventListener("mouseleave", (e) => {
    e.target.style.color = "#8b949e";
  });
}

// Sayfa yüklenince çalıştır
document.addEventListener("DOMContentLoaded", authKontrol);
