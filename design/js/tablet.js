// Clock update
function updateClock() {
  const el = document.querySelector('.statusbar-time');
  if (!el) return;
  const now = new Date();
  const h = String(now.getHours()).padStart(2, '0');
  const m = String(now.getMinutes()).padStart(2, '0');
  el.textContent = h + ':' + m;
}
updateClock();
setInterval(updateClock, 10000);

// Toast notification
let toastTimer;
function showToast(msg) {
  let t = document.getElementById('toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'toast';
    t.className = 'toast';
    t.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span id="toast-msg"></span>`;
    document.querySelector('.device')?.appendChild(t);
  }
  const msgEl = document.getElementById('toast-msg');
  if (msgEl) msgEl.textContent = msg || 'Berhasil disimpan.';
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.classList.remove('show'), 3000);
}

// Sub-tabs switcher (generic)
function switchTab(tabEl, contentId) {
  const container = tabEl.closest('.detail-pane') || tabEl.closest('.screen') || document;
  container.querySelectorAll('.sub-tab').forEach(t => t.classList.remove('active'));
  tabEl.classList.add('active');
  const scroll = container.querySelector('.detail-scroll') || document;
  scroll.querySelectorAll('.tc').forEach(c => c.classList.remove('active'));
  const target = document.getElementById(contentId);
  if (target) target.classList.add('active');
}

// Calc tabs switcher
function switchCalc(tabEl, contentId) {
  tabEl.parentElement.querySelectorAll('.calc-tab').forEach(t => t.classList.remove('active'));
  tabEl.classList.add('active');
  const scrollEl = tabEl.closest('.calc-left')?.querySelector('.calc-scroll') || document;
  scrollEl.querySelectorAll('.tc').forEach(c => c.classList.remove('active'));
  const target = document.getElementById(contentId);
  if (target) target.classList.add('active');
}

// Chip filter active toggle
function setChip(el) {
  el.closest('.chips')?.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
}
