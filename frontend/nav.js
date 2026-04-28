// Ortak navigasyon - tüm sayfalarda kullanılır
const NAV_ITEMS = [
  { href: "/",              label: "Veri Yukleme",     icon: "⬆" },
  { href: "/karlilik.html", label: "Karlilik Analizi", icon: "📊" },
  { href: "/mutabakat.html",label: "Mutabakat",        icon: "✅" },
];

function renderNav() {
  const current = window.location.pathname;
  const nav = document.getElementById("mainNav");
  if (!nav) return;

  nav.innerHTML = NAV_ITEMS.map(item => {
    const isActive = (item.href === "/" && (current === "/" || current === "/index.html"))
      || (item.href !== "/" && current.includes(item.href.replace("/","")));
    return `<a href="${item.href}" class="nav-link ${isActive ? "active" : ""}">
      <span class="nav-icon">${item.icon}</span>
      <span>${item.label}</span>
    </a>`;
  }).join("");
}

document.addEventListener("DOMContentLoaded", renderNav);
