/*
 * Aplyd Sandbox: app list
 * ------------------------------------------------------------------
 * To add an app, copy one object below and edit it. Fields:
 *   name         Display name on the card
 *   category     Short label shown above the name
 *   description  One line, plain language, no metrics
 *   url          Where the "Open" button goes (opens in the same tab)
 *   icon         One of: "health", "agriculture", "education", "academy", "spark"
 *   loginRequired  true shows the "Login required" tag
 * Also add a matching <li> to the <noscript> list in index.html.
 */
const APPS = [
  {
    name: "Saha Health",
    category: "Health",
    description: "An AI assistant prototype that gives frontline health workers clear, guideline-based answers in plain language.",
    url: "https://health.aplyd.org",
    icon: "health",
    loginRequired: true,
  },
  {
    name: "Saha Agriculture",
    category: "Agriculture",
    description: "An AI assistant prototype that helps extension workers and farmers find practical, timely crop and farm advice.",
    url: "https://agriculture.aplyd.org",
    icon: "agriculture",
    loginRequired: true,
  },
  {
    name: "Saha Education",
    category: "Education",
    description: "An AI assistant prototype that supports teachers and education staff with lesson planning and quick answers.",
    url: "https://education.aplyd.org",
    icon: "education",
    loginRequired: true,
  },
  {
    name: "Aplyd Academy",
    category: "Learning",
    description: "A learning platform for building practical AI skills across teams and partner institutions.",
    url: "https://academy.aplyd.org",
    icon: "academy",
    loginRequired: true,
  },
];

/* ---------------- Rendering (no need to edit below) ---------------- */
(function () {
  const ICONS = {
    health:
      '<path d="M19 14c1.5-1.5 3-3.2 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.8 0-3 .5-4.5 2-1.5-1.5-2.7-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4 3 5.5l7 7Z"/><path d="M3.5 12h6l1-2 2 4.5 2-7 1.5 4.5h4.5"/>',
    agriculture:
      '<path d="M7 20h10"/><path d="M10 20c5.5-2.5.8-6.4 3-10"/><path d="M9.5 9.4c1.1.8 1.8 2.2 2.3 3.7-2 .4-3.5.4-4.8-.3-1.2-.6-2.3-1.9-3-4.2 2.8-.5 4.4 0 5.5.8Z"/><path d="M14.1 6a7 7 0 0 0-1.1 4c1.9-.1 3.3-.6 4.3-1.4 1-1 1.6-2.3 1.7-4.6-2.7.1-4 1-4.9 2Z"/>',
    education:
      '<path d="M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2Z"/><path d="M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7Z"/>',
    academy:
      '<path d="M21.4 10.9a1 1 0 0 0 0-1.8L12.8 5.2a2 2 0 0 0-1.7 0L2.6 9.1a1 1 0 0 0 0 1.8l8.6 3.9a2 2 0 0 0 1.7 0Z"/><path d="M22 10v6"/><path d="M6 12.5V16a6 3 0 0 0 12 0v-3.5"/>',
    spark:
      '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8"/>',
  };
  const svg = (paths, cls) =>
    '<svg class="' + cls + '" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' + paths + "</svg>";
  const esc = (s) =>
    String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const host = (u) => {
    try { return new URL(u).host; } catch (e) { return u; }
  };

  function render() {
    const grid = document.getElementById("app-grid");
    if (!grid) return;
    grid.innerHTML = APPS.map((app, i) => {
      const id = "app-" + i;
      const lock = app.loginRequired
        ? '<span class="tag tag-lock">' + svg('<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>', "icon") + "Login required</span>"
        : "";
      return (
        '<li class="card" style="--i:' + i + '">' +
          '<div class="card-top">' +
            '<span class="card-icon">' + svg(ICONS[app.icon] || ICONS.spark, "icon") + "</span>" +
            lock +
          "</div>" +
          '<p class="card-kicker">' + esc(app.category) + "</p>" +
          '<h3 class="card-title" id="' + id + '">' + esc(app.name) + "</h3>" +
          '<p class="card-desc">' + esc(app.description) + "</p>" +
          '<div class="card-foot">' +
            '<span class="card-host">' + esc(host(app.url)) + "</span>" +
            '<a class="btn btn-gold btn-sm" href="' + esc(app.url) + '">' +
              'Open<span class="sr-only"> ' + esc(app.name) + "</span>" +
              svg('<path d="M5 12h14M13 6l6 6-6 6"/>', "icon") +
            "</a>" +
          "</div>" +
        "</li>"
      );
    }).join("");
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", render);
  else render();
})();
