/* yg_properties NUI — vanilla, no build step, no CDN. */
const root = document.getElementById('root');
const toasts = document.getElementById('toasts');
const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'yg_properties';
const post = (n, d = {}) => fetch(`https://${RES}/${n}`, {
  method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(d)
}).then(r => r.json().catch(() => ({}))).catch(() => ({}));
const E = (t, c, h) => { const e = document.createElement(t); if (c) e.className = c; if (h != null) e.innerHTML = h; return e; };

/* ---- icons ---- */
const S = i => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${i}</svg>`;
const I = {
  house: S('<path d="M3 11l9-7 9 7M5 10v10h14V10M9 20v-6h6v6"/>'),
  info: S('<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>'),
  brush: S('<path d="M3 21c3 0 4-2 4-4l9-9-3-3-9 9c-2 0-4 1-4 4z"/><path d="M14 6l4 4"/>'),
  key: S('<circle cx="8" cy="8" r="4"/><path d="M11 11l9 9M16 16l2-2"/>'),
  users: S('<circle cx="9" cy="8" r="3"/><path d="M3 20c0-3 3-5 6-5s6 2 6 5M16 6a3 3 0 0 1 0 6"/>'),
  ticket: S('<path d="M3 8a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2 2 2 0 0 0 0 4 2 2 0 0 1-2 2H5a2 2 0 0 1-2-2 2 2 0 0 0 0-4z"/>'),
  pin: S('<path d="M12 21s7-6 7-11a7 7 0 1 0-14 0c0 5 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/>'),
  tag: S('<path d="M3 12V5a2 2 0 0 1 2-2h7l9 9-9 9z"/><path d="M8 8h.01"/>'),
  cog: S('<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M4 12H2M22 12h-2M5 5l2 2M17 17l2 2M19 5l-2 2M7 17l-2 2"/>'),
  filter: S('<path d="M3 5h18l-7 8v6l-4-2v-4z"/>'),
  x: S('<path d="M6 6l12 12M18 6L6 18"/>'),
  lock: S('<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>'),
  cart: S('<circle cx="9" cy="20" r="1.6"/><circle cx="18" cy="20" r="1.6"/><path d="M2 3h3l2.5 13h11l2-9H6"/>'),
  box: S('<path d="M21 8l-9-5-9 5 9 5 9-5zM3 8v8l9 5 9-5V8M12 13v8"/>'),
  chest: S('<rect x="3" y="9" width="18" height="11" rx="2"/><path d="M3 13h18M9 13v3"/>'),
  shirt: S('<path d="M16 4l4 3-2 3-2-1.5V20H8V8.5L6 10 4 7l4-3 2 2h0a2 2 0 0 0 4 0z"/>'),
  plus: S('<path d="M12 5v14M5 12h14"/>'),
  sofa: S('<path d="M4 11V8a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v3M3 11a2 2 0 0 1 2 2v3h14v-3a2 2 0 0 1 2-2 2 2 0 0 0-2-2 2 2 0 0 0-2 2v1H7v-1a2 2 0 0 0-2-2 2 2 0 0 0-2 2zM6 19v1M18 19v1"/>'),
  bulb: S('<path d="M9 18h6M10 21h4M12 3a6 6 0 0 1 4 10c-.7.7-1 1.5-1 2H9c0-.5-.3-1.3-1-2a6 6 0 0 1 4-10z"/>'),
  plant: S('<path d="M12 22V12M12 12C12 8 9 5 4 5c0 4 3 7 8 7zM12 11c0-3 3-6 8-6 0 4-4 6-8 6z"/>'),
  tv: S('<rect x="3" y="5" width="18" height="12" rx="2"/><path d="M8 21h8M12 17v4"/>'),
  fence: S('<path d="M4 9l2-2 2 2M4 9v8h4V9M14 9l2-2 2 2v8h-4V9M2 13h20"/>'),
  door: S('<path d="M5 21V4a1 1 0 0 1 1-1h9a1 1 0 0 1 1 1v17M3 21h18M13 12h.01"/>'),
  search: S('<circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/>'),
  sliders: S('<path d="M4 6h16M4 12h16M4 18h16"/><circle cx="9" cy="6" r="2" fill="currentColor" stroke="none"/><circle cx="16" cy="12" r="2" fill="currentColor" stroke="none"/><circle cx="7" cy="18" r="2" fill="currentColor" stroke="none"/>'),
  office: S('<rect x="4" y="3" width="16" height="18" rx="1.5"/><path d="M8 7h2M14 7h2M8 11h2M14 11h2M8 15h2M14 15h2M10 21v-4h4v4"/>'),
  crosshair: S('<circle cx="12" cy="12" r="8"/><path d="M12 2v4M12 18v4M2 12h4M18 12h4"/>'),
  cloud: S('<path d="M17.5 19a4.5 4.5 0 0 0 0-9 6 6 0 0 0-11.6 1.8A4 4 0 0 0 6.5 19h11z"/>'),
};
const icon = k => I[k] || I.box;
const PERM_LABELS = {
  employeesCanEnter: 'İçeri girebilsin',
  employeesCanManage: 'Panel açabilsin',
  employeesCanManageDoor: 'Kilidi yönetebilsin',
  employeesCanSetEntryFee: 'Giriş ücreti ayarlayabilsin',
  employeesCanEditDescription: 'Açıklama düzenleyebilsin',
  employeesCanBuild: 'Build/dekor yapabilsin',
  employeesCanDeposit: 'Kasaya para koyabilsin',
  employeesCanWithdraw: 'Kasadan para çekebilsin',
  employeesCanManageEmployees: 'Çalışan yönetebilsin',
};
function categoryIcon(name) {
  const n = (name || '').toLowerCase();
  if (/duvar|çit|fence|panel/.test(n)) return 'fence';
  if (/ışık|lamba|aydınlat|light|lamp/.test(n)) return 'bulb';
  if (/bitki|plant|saksı|çiçek/.test(n)) return 'plant';
  if (/dekor|halı|rug|tablo|süs/.test(n)) return 'plant';
  if (/tv|elektronik|ekran|ses|sound/.test(n)) return 'tv';
  if (/dış|outdoor|bahçe|patio/.test(n)) return 'fence';
  if (/kapı|door/.test(n)) return 'door';
  if (/koltuk|masa|sandalye|yatak|dolap|mobilya|sofa|furniture/.test(n)) return 'sofa';
  return 'box';
}

/* ---- toast ---- */
function toast(msg) {
  const t = E('div', 'toast', msg); toasts.appendChild(t);
  setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 250); }, 3500);
}
function clear() { root.innerHTML = ''; }

// ✅ Giriş bekleme ekranı ("Yükleniyor...") — BİLEREK document.body'ye
// ekleniyor, #root'a DEĞİL. Sebep: diğer ekranlar açılıp kapanırken
// #root sürekli clear() ile boşaltılıyor — eğer bu overlay #root
// içinde olsaydı, mekana girerken tetiklenen herhangi bir başka NUI
// render'ı (örn. bir bildirim ekranı) onu istemeden silebilirdi.
// document.body'de kalıcı durduğu için hangi ekran açılıp kapanırsa
// kapansın etkilenmiyor.
function showLoadingOverlay() {
  if (document.getElementById('ygLoadingOverlay')) return;
  const ov = document.createElement('div');
  ov.id = 'ygLoadingOverlay';
  ov.className = 'yg-loading-overlay';
  ov.innerHTML = `<div class="yg-loading-text">Yükleniyor<span class="yg-loading-dots"><span>.</span><span>.</span><span>.</span></span></div>`;
  document.body.appendChild(ov);
}
function hideLoadingOverlay() {
  const ov = document.getElementById('ygLoadingOverlay');
  if (ov) ov.remove();
}

function close() { clear(); post('yg_close'); post('close'); }

/* oyun-içi modal (browser prompt/confirm yerine) */
function modalInput(title, placeholder, onOk) {
  const bg = E('div', 'modalbg');
  bg.innerHTML = `<div class="modalbox"><div class="modaltitle">${title}</div></div>`;
  const box = bg.querySelector('.modalbox');
  const inp = E('input', 'in'); inp.placeholder = placeholder || '';
  box.appendChild(inp);
  const row = E('div', 'modalrow');
  const ok = E('button', 'fbtn primary', 'Tamam');
  const ca = E('button', 'fbtn', 'İptal');
  ok.onclick = () => { const v = inp.value.trim(); bg.remove(); if (v) onOk(v); };
  ca.onclick = () => bg.remove();
  inp.addEventListener('keydown', e => { if (e.key === 'Enter') ok.click(); if (e.key === 'Escape') ca.click(); });
  row.append(ca, ok); box.appendChild(row);
  root.appendChild(bg); setTimeout(() => inp.focus(), 30);
}
function modalConfirm(text, onYes) {
  const bg = E('div', 'modalbg');
  bg.innerHTML = `<div class="modalbox"><div class="modaltitle">${text}</div></div>`;
  const box = bg.querySelector('.modalbox');
  const row = E('div', 'modalrow');
  const yes = E('button', 'fbtn primary', 'Evet');
  const no = E('button', 'fbtn', 'İptal');
  yes.onclick = () => { bg.remove(); onYes(); };
  no.onclick = () => bg.remove();
  row.append(no, yes); box.appendChild(row); root.appendChild(bg);
}

/* ============================================================
   MANAGEMENT PANEL — "İş Yeri Yönetim Merkezi" referansının
   düzenine uyarlandı: sol nav ile sayfa değiştirme + sağ tarafta
   ayrı, kapatılabilir "Mülk Detayları" özet paneli.

   DÜRÜST NOT: Referansta gördüğün "Kira / hafta", "Özel Alanlar",
   "Kapasite (610 Dolu)", harita küçük resmi gibi alanlar bizim
   script'imizde YOK — bunları uydurmadım. Sağ panelde SADECE
   gerçekten var olan verileri (tür, kilit durumu, kasa, giriş
   ücreti, anahtar/çalışan sayısı) gösteriyorum.

   Ev/işletme ayrımı (önceki turdan korunuyor):
     - Gardırop Noktası → SADECE EV
     - Finans (Giriş Ücreti) + Çalışanlar sayfası → SADECE İŞLETME
   ============================================================ */
let MG = null; // {propertyId, mgmt, keys, myProperties, permKeys}
let tab = 'props';
let mgPage = 'info';      // 'info' | 'finance' | 'employees' | 'keyholders'
let mgDetailsOpen = true; // sağ "Mülk Detayları" paneli açık/kapalı

function openManagement(d) {
  MG = d; MG.amOwner = !!d.amOwner; tab = 'props'; mgPage = 'info'; mgDetailsOpen = true; renderManagement();
}

function mgTopTabs() {
  const tabs = E('div', 'bd-tabs');
  [['props', 'box', 'Mülklerim'], ['keys', 'pin', 'Anahtarlarım']].forEach(([id, ic, lbl]) => {
    const b = E('button', 'bd-tab' + (tab === id ? ' on' : ''), `${icon(ic)}${lbl}`);
    b.onclick = () => { tab = id; if (id === 'keys') loadMyKeys(); else renderManagement(); };
    tabs.appendChild(b);
  });
  return tabs;
}

function renderManagement() {
  clear();
  const m = MG.mgmt || {};
  const isBiz = m.type === 'business';

  const floatTitle = E('div', 'mg-floattitle',
    `<div class="mg-floatbadge">${icon(isBiz ? 'office' : 'house')}</div>${isBiz ? 'İŞ YERİ YÖNETİM MERKEZİ' : 'EV YÖNETİM MERKEZİ'}`);
  root.appendChild(floatTitle);

  const outer = E('div', 'mg-outer');

  // ✅ EKLENDİ: KOMPAKT ana panel — sol üstte, sadece mülk listesi +
  // yönetim menüsü. Tıklanan sayfa artık BURADA (inline) değil, sağa
  // doğru AYRI bir kutu (mg-pageflyout) olarak açılıyor — "Mülk
  // Detayları" panelinin (mg-details) zaten kullandığı AYNI yöntem.
  const wrap = E('div', 'mg-wrap mg-compact');
  const top = E('div', 'bd-top');
  top.innerHTML = `<div class="bd-top-l">
      <img class="rl-logo" id="mgLogo" src="img/logo.jpg" alt="">
      <div class="bd-titlewrap"><div class="bd-title">${m.label || 'Mekan'}</div><div class="bd-sub">${isBiz ? 'İşletme' : 'Ev'}</div></div></div>`;
  const mgLogo = top.querySelector('#mgLogo');
  if (mgLogo) mgLogo.onerror = () => { mgLogo.outerHTML = `<div class="bd-badge">${icon(isBiz ? 'office' : 'house')}</div>`; };
  top.appendChild(mgTopTabs());
  const detailsToggle = E('button', 'ibtn', icon('info'));
  detailsToggle.setAttribute('data-tip', 'Mülk Detayları');
  detailsToggle.onclick = () => { mgDetailsOpen = !mgDetailsOpen; renderManagement(); };
  top.appendChild(detailsToggle);
  const closeBtn = E('button', 'ibtn x', icon('x'));
  closeBtn.onclick = close;
  top.appendChild(closeBtn);
  wrap.appendChild(top);

  const body = E('div', 'mg-content');
  if (tab === 'props') body.appendChild(renderNavRail(isBiz));
  else body.appendChild(E('div', 'empty', 'Yükleniyor...'));
  wrap.appendChild(body);

  outer.appendChild(wrap);
  // ✅ EKLENDİ: seçili sayfa artık ayrı bir flyout — ana panelin hemen
  // sağına, ona bitişik açılıyor.
  if (tab === 'props') outer.appendChild(renderMgPageFlyout(isBiz));
  if (mgDetailsOpen && tab === 'props') outer.appendChild(renderMgDetails(isBiz));
  root.appendChild(outer);
}

// ✅ EKLENDİ: kompakt ana paneldeki nav rayı (mülk listesi + yönetim
// menüsü) — eskiden renderPropsTab içinde .mg-page ile YAN YANA
// duruyordu, artık TEK BAŞINA (sayfa içeriği ayrı flyout'ta).
function renderNavRail(isBiz) {
  const m = MG.mgmt || {};
  const rail = E('div', 'mg-navrail mg-navrail-compact');
  rail.appendChild(E('div', 'bd-rail-eyebrow', 'YÖNETİM'));
  const navList = [
    { ic: 'home', lbl: 'Mülk Bilgileri', page: 'info' },
    { ic: 'chest', lbl: 'Depo Noktası', fn: () => post('yg_setStashPoint', { propertyId: MG.propertyId }).then(() => toast('Depo noktası kondu.')) },
    { ic: 'brush', lbl: 'Mekanı Döşe', fn: () => post('yg_furnish', {}) },
    { ic: 'box', lbl: 'Objeleri Yönet', fn: () => post('yg_manageObjects', {}) },
    { ic: 'key', lbl: 'Anahtar Sahipleri', sub: `${(MG.keys || []).length} kişi`, page: 'keyholders' },
    { ic: 'cloud', lbl: 'Ortam', sub: (m.blackout ? 'Karartma açık' : (m.weather || 'Varsayılan')), page: 'weather' },
  ];
  if (!isBiz) navList.splice(2, 0, { ic: 'shirt', lbl: 'Gardırop Noktası', fn: () => post('yg_setWardrobePoint', { propertyId: MG.propertyId }).then(() => toast('Gardırop noktası kondu.')) });
  if (isBiz) {
    navList.push({ ic: 'ticket', lbl: 'Finans', sub: 'Giriş Ücreti', page: 'finance' });
    navList.push({ ic: 'users', lbl: 'Çalışanlar', sub: `${Object.keys(m.employees || {}).length} kişi`, page: 'employees' });
  }
  const nav = E('div', 'mg-navlist');
  navList.forEach(item => {
    const active = item.page && mgPage === item.page;
    const row = E('button', 'mg-navitem' + (active ? ' on' : ''),
      `<span class="mg-navicon">${icon(item.ic)}</span><span class="mg-navtext"><span class="mg-navlabel">${item.lbl}</span>${item.sub ? `<small>${item.sub}</small>` : ''}</span>`);
    row.onclick = () => { if (item.page) { mgPage = item.page; renderManagement(); } else if (item.fn) item.fn(); };
    nav.appendChild(row);
  });
  rail.appendChild(nav);

  const sell = E('button', 'mg-sellbtn', `${icon('tag')} Mülkü Sat`);
  sell.onclick = () => modalConfirm('Mülkü satmak istediğine emin misin?', () => post('yg_sell', { propertyId: MG.propertyId }).then(close));
  rail.appendChild(sell);
  return rail;
}

// ✅ EKLENDİ: seçili yönetim sayfası (Bilgiler/Ortam/Anahtarlar/Finans/
// Çalışanlar) artık BAĞIMSIZ bir flyout kutusu — mg-details ile AYNI
// görsel stil, ana panelin hemen sağında açılıyor.
function renderMgPageFlyout(isBiz) {
  const panel = E('div', 'mg-pageflyout');
  const head = E('div', 'mg-details-head');
  const pageNames = { info: 'MÜLK BİLGİLERİ', weather: 'ORTAM', keyholders: 'ANAHTAR SAHİPLERİ', finance: 'FİNANS', employees: 'ÇALIŞANLAR' };
  head.innerHTML = `<span>${icon('sliders')} ${pageNames[mgPage] || 'YÖNETİM'}</span>`;
  panel.appendChild(head);

  const page = E('div', 'mg-page');
  if (mgPage === 'finance' && isBiz) page.appendChild(renderMgFinancePage());
  else if (mgPage === 'employees' && isBiz) page.appendChild(renderMgEmployeesPage());
  else if (mgPage === 'keyholders') page.appendChild(renderMgKeyholdersPage());
  else if (mgPage === 'weather') page.appendChild(renderMgWeatherPage());
  else page.appendChild(renderMgInfoPage(isBiz));
  panel.appendChild(page);
  return panel;
}

function renderMgInfoPage(isBiz) {
  const m = MG.mgmt || {};
  const wrap = E('div');
  wrap.appendChild(E('div', 'mg-pagehead', 'Mülk Bilgileri'));

  const card = E('div', 'mg-card');
  card.appendChild(E('div', 'mg-lbl', 'Mülk İsmi'));
  const lab = E('input', 'mg-input'); lab.value = m.label || ''; lab.placeholder = 'Mülk ismi girin';
  lab.onchange = () => post('yg_setLabel', { propertyId: MG.propertyId, label: lab.value });
  card.appendChild(lab);

  card.appendChild(E('div', 'mg-lbl', 'Açıklama'));
  const desc = E('textarea', 'mg-input mg-desc'); desc.value = m.description || ''; desc.placeholder = 'Mülk açıklaması';
  desc.onchange = () => post('yg_setDescription', { propertyId: MG.propertyId, description: desc.value });
  card.appendChild(desc);
  wrap.appendChild(card);

  // ✅ DEĞİŞTİ: artık dekoratif değil — emlakçıda kullandığımız GERÇEK
  // haritayı (img/map.jpg) ve AYNI koordinat dönüşümünü (rlWorldToMap)
  // kullanıp, bu mülkün GERÇEK konumunu (door_coords) pin olarak
  // gösteriyor.
  const locCard = E('div', 'mg-card');
  locCard.appendChild(E('div', 'mg-lbl', 'Konum'));
  const mapBox = E('div', 'mg-mapbox');
  let doorCoords = null;
  try { doorCoords = typeof m.door_coords === 'string' ? JSON.parse(m.door_coords) : m.door_coords; } catch (e) { doorCoords = null; }
  if (doorCoords && typeof doorCoords.x === 'number') {
    const { mx, my } = rlWorldToMap(doorCoords.x, doorCoords.y);
    const pctX = (mx / RL_MAP.w) * 100, pctY = (my / RL_MAP.h) * 100;
    mapBox.innerHTML = `<img class="mg-mapbox-img" src="img/map.jpg" alt="harita"
        onerror="this.style.display='none'">
      <svg class="mg-mapbox-pin" viewBox="0 0 28 28" style="left:${pctX}%; top:${pctY}%">
        <path d="M14,26 C11,17 3,13 3,7 A11,11 0 1,1 25,7 C25,13 17,17 14,26 Z"/>
        <circle cx="14" cy="7" r="4.2" fill="#171009"/>
      </svg>`;
  } else {
    mapBox.innerHTML = `${icon('pin')}<span>Konum verisi yok</span>`;
  }
  locCard.appendChild(mapBox);
  wrap.appendChild(locCard);

  const card2 = E('div', 'mg-card');
  card2.appendChild(E('div', 'mg-lbl', 'Kasa Parası: $' + (m.stash_money || 0).toLocaleString('en-US')));
  const moneyRow = E('div', 'mg-rowf');
  const amt = E('input', 'mg-input'); amt.type = 'number'; amt.placeholder = 'Tutar';
  const dep = E('button', 'bd-mini', 'Yatır'); dep.onclick = () => post('yg_deposit', { propertyId: MG.propertyId, amount: amt.value });
  const wd = E('button', 'bd-mini', 'Çek'); wd.onclick = () => post('yg_withdraw', { propertyId: MG.propertyId, amount: amt.value });
  moneyRow.append(amt, dep, wd); card2.appendChild(moneyRow);
  wrap.appendChild(card2);

  return wrap;
}

function renderMgFinancePage() {
  const m = MG.mgmt || {};
  const wrap = E('div');
  wrap.appendChild(E('div', 'mg-pagehead', 'Finans — Giriş Ücreti'));
  const card = E('div', 'mg-card');
  card.appendChild(E('div', 'mg-lbl', 'Giriş Ücreti: $' + (m.entry_fee || 0)));
  const fee = E('input', 'mg-input'); fee.type = 'number'; fee.value = m.entry_fee || 0;
  fee.onchange = () => post('yg_setEntryFee', { propertyId: MG.propertyId, fee: fee.value });
  card.appendChild(fee);
  wrap.appendChild(card);
  return wrap;
}

const MG_WEATHERS = [
  ['', 'Varsayılan (Dış Dünya)'], ['CLEAR', 'Açık'], ['EXTRASUNNY', 'Güneşli'],
  ['CLOUDS', 'Bulutlu'], ['OVERCAST', 'Kapalı'], ['RAIN', 'Yağmurlu'],
  ['THUNDER', 'Fırtınalı'], ['FOGGY', 'Sisli'], ['SMOG', 'Dumanlı'],
  ['SNOWLIGHT', 'Hafif Kar'], ['BLIZZARD', 'Kar Fırtınası'], ['NEUTRAL', 'Nötr'],
];
function renderMgWeatherPage() {
  const m = MG.mgmt || {};
  const wrap = E('div');
  wrap.appendChild(E('div', 'mg-pagehead', 'Ortam — Hava Durumu, Saat & Karartma'));
  const card = E('div', 'mg-card');
  card.appendChild(E('div', 'mg-lbl', 'Bu mekana SADECE içeri girenler görür — dışarıdaki oyuncuları etkilemez'));
  const grid = E('div', 'mg-weathergrid');
  const current = (m.weather || '').toUpperCase();
  MG_WEATHERS.forEach(([val, label]) => {
    const isOn = (val === '' && !current) || val === current;
    const b = E('button', 'mg-weatherbtn' + (isOn ? ' on' : ''), label);
    b.onclick = () => { post('yg_setWeather', { propertyId: MG.propertyId, weather: val }); m.weather = val; renderManagement(); };
    grid.appendChild(b);
  });
  card.appendChild(grid);
  wrap.appendChild(card);

  // ✅ EKLENDİ: Saat kontrolü — hava durumu/karartma ile AYNI mantık
  // (NetworkOverrideClockTime, client-taraflı, sadece içeridekini etkiler).
  const tcard = E('div', 'mg-card');
  tcard.appendChild(E('h3', null, 'SAAT'));
  tcard.appendChild(E('div', 'mg-lbl', 'Mekana özel saat kilitler (gün döngüsü durur) — sadece içeridekiler görür'));
  const tgrid = E('div', 'mg-weathergrid');
  const curTime = m.time_of_day || '';
  const TIME_PRESETS = [['', 'Varsayılan'], ['08:00', '☀️ Sabah'], ['13:00', '🌤️ Öğle'], ['19:00', '🌆 Akşam'], ['23:00', '🌙 Gece'], ['03:00', '🌑 Gece Yarısı']];
  TIME_PRESETS.forEach(([val, label]) => {
    const isOn = val === curTime || (val === '' && !curTime);
    const b = E('button', 'mg-weatherbtn' + (isOn ? ' on' : ''), label);
    b.onclick = () => { post('yg_setTime', { propertyId: MG.propertyId, time: val }); m.time_of_day = val; renderManagement(); };
    tgrid.appendChild(b);
  });
  tcard.appendChild(tgrid);
  const trow = E('div', 'mg-rowf');
  const tinput = E('input', 'mg-input'); tinput.type = 'time'; tinput.value = curTime || '12:00';
  const tset = E('button', 'bd-mini', 'Bu Saati Kullan');
  tset.onclick = () => { post('yg_setTime', { propertyId: MG.propertyId, time: tinput.value }); m.time_of_day = tinput.value; renderManagement(); };
  trow.append(tinput, tset);
  tcard.appendChild(trow);
  wrap.appendChild(tcard);

  const bcard = E('div', 'mg-card');
  bcard.appendChild(E('h3', null, 'KARARTMA (BLACKOUT)'));
  bcard.appendChild(E('div', 'mg-lbl', 'Işıkları söndürüp mekanı karartır — sadece içeridekiler görür'));
  const bgrid = E('div', 'mg-weathergrid');
  const bOn = E('button', 'mg-weatherbtn' + (m.blackout ? ' on' : ''), '🌑 Karanlık');
  bOn.onclick = () => { post('yg_setBlackout', { propertyId: MG.propertyId, state: true }); m.blackout = true; renderManagement(); };
  const bOff = E('button', 'mg-weatherbtn' + (!m.blackout ? ' on' : ''), '💡 Aydınlık');
  bOff.onclick = () => { post('yg_setBlackout', { propertyId: MG.propertyId, state: false }); m.blackout = false; renderManagement(); };
  bgrid.append(bOn, bOff);
  bcard.appendChild(bgrid);
  wrap.appendChild(bcard);

  return wrap;
}

function renderMgEmployeesPage() {
  const m = MG.mgmt || {};
  const wrap = E('div');
  wrap.appendChild(E('div', 'mg-pagehead', 'Çalışanlar'));

  const ecard = E('div', 'mg-card');
  const emps = m.employees || {};
  const empCids = Object.keys(emps);
  const elist = E('div', 'mg-rowlist');
  if (empCids.length === 0) elist.appendChild(E('div', 'empty', 'Çalışan yok.'));
  empCids.forEach(cidKey => {
    const r = E('div', 'mg-row');
    r.innerHTML = `<div class="mg-rowicon">${icon('users')}</div><div class="mg-rowinfo"><div class="mg-rowname">${cidKey}</div></div>`;
    const fire = E('button', 'bd-mini danger', 'Kov');
    fire.onclick = async () => { await post('yg_removeEmployee', { propertyId: MG.propertyId, citizenid: cidKey }); delete emps[cidKey]; renderManagement(); };
    r.appendChild(fire); elist.appendChild(r);
  });
  ecard.appendChild(elist);
  const add = E('button', 'mg-addbtn', `${icon('plus')} Çalışan Ekle (CitizenID)`);
  add.onclick = () => modalInput('Çalışan Ekle', 'CitizenID', cid => post('yg_addEmployee', { propertyId: MG.propertyId, target: cid }).then(() => { toast('Çalışan eklendi.'); post('yg_mgmtSelect', { propertyId: MG.propertyId }).then(r => { if (r && r.mgmt) { MG.mgmt = r.mgmt; MG.amOwner = !!r.amOwner; renderManagement(); } }); }));
  ecard.appendChild(add);
  wrap.appendChild(ecard);

  if (MG.amOwner) {
    const pcard = E('div', 'mg-card');
    pcard.appendChild(E('h3', null, 'ÇALIŞAN YETKİLERİ'));
    const pd = E('div', 'mg-permlist');
    Object.keys(PERM_LABELS).forEach(pk => {
      const lab2 = E('label', 'mg-chk');
      const cb = E('input'); cb.type = 'checkbox';
      cb.checked = !!(m.permissions && m.permissions[pk]);
      cb.onchange = () => post('yg_setPermission', { propertyId: MG.propertyId, key: pk, value: cb.checked });
      lab2.append(cb, document.createTextNode(PERM_LABELS[pk]));
      pd.appendChild(lab2);
    });
    pcard.appendChild(pd);
    wrap.appendChild(pcard);
  }
  return wrap;
}

function renderMgKeyholdersPage() {
  const wrap = E('div');
  wrap.appendChild(E('div', 'mg-pagehead', 'Anahtar Sahipleri'));
  const card = E('div', 'mg-card');
  const list = E('div', 'mg-rowlist');
  (MG.keys || []).forEach(k => {
    const r = E('div', 'mg-row');
    r.innerHTML = `<div class="mg-rowicon">${icon('key')}</div><div class="mg-rowinfo"><div class="mg-rowname">${k.name || k.citizenid}</div><div class="mg-rowmeta">${k.citizenid}</div></div>`;
    const rm = E('button', 'bd-mini danger', 'Sil');
    rm.onclick = async () => { const res = await post('yg_removeKey', { propertyId: MG.propertyId, citizenid: k.citizenid }); MG.keys = res.keys || []; renderManagement(); };
    r.appendChild(rm); list.appendChild(r);
  });
  if ((MG.keys || []).length === 0) list.appendChild(E('div', 'empty', 'Henüz anahtar verilmemiş.'));
  card.appendChild(list);
  const give = E('button', 'mg-addbtn', `${icon('plus')} Anahtar Ver (server ID)`);
  give.onclick = () => modalInput('Anahtar Ver', 'Oyuncunun Server ID\'si', async sid => { const res = await post('yg_giveKey', { propertyId: MG.propertyId, target: sid }); MG.keys = res.keys || MG.keys; renderManagement(); });
  card.appendChild(give);
  wrap.appendChild(card);
  return wrap;
}

function renderMgDetails(isBiz) {
  const m = MG.mgmt || {};
  const panel = E('div', 'mg-details');
  const head = E('div', 'mg-details-head');
  head.innerHTML = `<span>${icon('info')} MÜLK DETAYLARI</span>`;
  const x = E('button', 'ibtn x', icon('x'));
  x.onclick = () => { mgDetailsOpen = false; renderManagement(); };
  head.appendChild(x);
  panel.appendChild(head);

  // Mülkün satın alındığı emlakçı kataloğu seçeneğinde "img" tanımlıysa
  // (html/img/ altında gerçek dosya varsa) gösterilir — yoksa hiç alan
  // ayrılmaz, panel eskisi gibi direkt satırlara geçer.
  if (m.img) {
    const photo = E('div', 'mg-details-photo');
    const im = E('img'); im.src = `img/${m.img}`; im.alt = '';
    im.onerror = () => photo.remove();
    photo.appendChild(im);
    panel.appendChild(photo);
  }

  const rows = [
    ['Tür', isBiz ? 'İşletme' : 'Ev'],
    ['Durum', m.locked ? '🔒 Kilitli' : '🔓 Açık'],
    ['Karartma', m.blackout ? '🌑 Açık' : '💡 Kapalı'],
    ['Saat', m.time_of_day || 'Varsayılan'],
    ['Kasa Parası', '$' + (m.stash_money || 0).toLocaleString('en-US')],
  ];
  if (isBiz) rows.push(['Giriş Ücreti', '$' + (m.entry_fee || 0)]);
  rows.push(['Anahtar Sayısı', `${(MG.keys || []).length} kişi`]);
  if (isBiz) rows.push(['Çalışan Sayısı', `${Object.keys(m.employees || {}).length} kişi`]);

  const list = E('div', 'mg-detailrows');
  rows.forEach(([k, v]) => {
    const r = E('div', 'mg-detailrow');
    r.innerHTML = `<span class="mg-dk">${k}</span><span class="mg-dv">${v}</span>`;
    list.appendChild(r);
  });
  panel.appendChild(list);

  // ✅ EKLENDİ: Aksiyonlar — Kilitle/Aç, Anahtar Ver, Sat GERÇEK
  // (mevcut) işlevlere bağlı.
  panel.appendChild(E('div', 'mg-detail-eyebrow', 'AKSİYONLAR'));
  const actions = E('div', 'mg-actiongrid');
  const lockBtn = E('button', 'mg-actionbtn', m.locked ? `${icon('lock')}<span>Aç</span>` : `${icon('lock')}<span>Kilitle</span>`);
  lockBtn.onclick = () => {
    post('yg_setLocked', { propertyId: MG.propertyId, locked: !m.locked });
    m.locked = !m.locked; mgDetailsOpen = true; renderManagement();
  };
  const keyBtn = E('button', 'mg-actionbtn', `${icon('key')}<span>Anahtar Ver</span>`);
  keyBtn.onclick = () => { mgPage = 'keyholders'; renderManagement(); };
  const sellBtn = E('button', 'mg-actionbtn danger', `${icon('tag')}<span>Sat</span>`);
  sellBtn.onclick = () => modalConfirm('Mülkü satmak istediğine emin misin?', () => post('yg_sell', { propertyId: MG.propertyId }).then(close));
  actions.append(lockBtn, keyBtn, sellBtn);
  panel.appendChild(actions);

  const spawnBtn = E('button', 'mg-spawnbtn', `${icon('pin')} SPAWN NOKTASINI TAŞI`);
  spawnBtn.onclick = () => post('yg_relocateSpawn', { propertyId: MG.propertyId });
  panel.appendChild(spawnBtn);

  return panel;
}

async function loadMyKeys() {
  renderManagement();
  const res = await post('yg_getMyKeysList', {});
  const content = root.querySelector('.mg-content'); if (!content) return; content.innerHTML = '';
  const list = E('div', 'mg-rowlist mg-rowlist-pad');
  (res.list || []).forEach(p => {
    const r = E('div', 'mg-row');
    r.innerHTML = `<div class="mg-rowicon">${icon('key')}</div><div class="mg-rowinfo"><div class="mg-rowname">${p.label || 'Mekan'}</div><div class="mg-rowmeta">${Number(p.is_owner) ? 'Sahip' : 'Anahtar'} • ${p.type === 'business' ? 'İşletme' : 'Ev'}</div></div>`;
    const go = E('button', 'bd-mini', 'Konum'); go.onclick = () => post('yg_gotoMyKey', { propertyId: p.id });
    r.appendChild(go); list.appendChild(r);
  });
  if ((res.list || []).length === 0) list.appendChild(E('div', 'empty', 'Hiç anahtarın yok.'));
  content.appendChild(list);
}
function topBar(title, back) {
  const top = E('div', 'top');
  top.innerHTML = `<div class="tl"><div class="badge">${icon('house')}</div><div class="tt">${title}</div></div>
    <div class="tr"><button class="ibtn" data-b="1">${icon('filter')}</button><button class="ibtn x" data-x="1">${icon('x')}</button></div>`;
  top.querySelector('[data-b]').onclick = back;
  top.querySelector('[data-x]').onclick = close;
  return top;
}

async function loadMyKeys() {
  renderManagement();
  const res = await post('yg_getMyKeysList', {});
  const content = root.querySelector('.mg-content'); if (!content) return; content.innerHTML = '';
  const list = E('div', 'mg-rowlist mg-rowlist-pad');
  (res.list || []).forEach(p => {
    const r = E('div', 'mg-row');
    r.innerHTML = `<div class="mg-rowicon">${icon('key')}</div><div class="mg-rowinfo"><div class="mg-rowname">${p.label || 'Mekan'}</div><div class="mg-rowmeta">${Number(p.is_owner) ? 'Sahip' : 'Anahtar'} • ${p.type === 'business' ? 'İşletme' : 'Ev'}</div></div>`;
    const go = E('button', 'bd-mini', 'Konum'); go.onclick = () => post('yg_gotoMyKey', { propertyId: p.id });
    r.appendChild(go); list.appendChild(r);
  });
  if ((res.list || []).length === 0) list.appendChild(E('div', 'empty', 'Hiç anahtarın yok.'));
  content.appendChild(list);
}

/* ============================================================
   REALTOR (kart-grid + harita) — sıfırdan tasarım
   ============================================================
   Harita NOT: Rockstar'ın gerçek Los Santos harita görselini
   kullanamıyoruz (telif hakkı) — bunun yerine kendi özgün, soyut
   "blueprint" tarzı bir şehir siluetini SVG olarak çiziyoruz. Hiç
   dış görsel/PNG istemiyor (NUI'de ekstra dosya yükü yok), ve pin'ler
   gerçek oyun-dünyası koordinatlarından (IPL'lerin spawn noktası)
   orantısal olarak hesaplanıyor.
*/
let RC = null;
let rlPtype = 'all';      // 'all' | 'home' | 'business'
let rlCatIdx = -1;        // -1 = seçili ptype içindeki TÜM kategoriler
let rlSearch = '';
let rlSort = 'default';   // 'default' | 'price_asc' | 'price_desc'
let rlHover = null;       // hover/seçili option key (kart <-> pin bağlantısı için)

// Oyun dünyası koordinat sınırları (GTA V playable map, kabaca) —
// haritadaki pin konumları bu aralığa göre ORANTISAL hesaplanıyor.
const RL_WORLD = { minX: -4000, maxX: 4500, minY: -4500, maxY: 8000 };
const RL_MAP = { w: 520, h: 760 };
function rlWorldToMap(x, y) {
  const nx = (x - RL_WORLD.minX) / (RL_WORLD.maxX - RL_WORLD.minX);
  const ny = (y - RL_WORLD.minY) / (RL_WORLD.maxY - RL_WORLD.minY);
  // pin şekli artık ucu (nokta) tam konumda, gövdesi YUKARI doğru ~40
  // birim uzuyor — üstten taşmasın diye dikeyde daha fazla boşluk bırakıyoruz.
  return { mx: Math.max(16, Math.min(RL_MAP.w - 16, nx * RL_MAP.w)), my: Math.max(44, Math.min(RL_MAP.h - 10, RL_MAP.h - ny * RL_MAP.h)) };
}

function openRealtor(d) {
  RC = (d.categories || []).map(cat => ({
    ...cat,
    options: (cat.options || []).map((o, i) => ({ ...o, _catId: cat.id, _optIndex: i + 1, _ptype: cat.ptype }))
  }));
  rlPtype = 'all'; rlCatIdx = -1; rlSearch = ''; rlSort = 'default'; rlHover = null;
  renderRealtor();
}

function rlVisibleCats() {
  return RC.filter(c => rlPtype === 'all' || c.ptype === rlPtype);
}

function rlFlatten() {
  const cats = rlCatIdx >= 0 ? [RC[rlCatIdx]] : rlVisibleCats();
  let list = [];
  cats.forEach(c => c && (c.options || []).forEach(o => list.push({ opt: o, cat: c })));
  const q = rlSearch.trim().toLowerCase();
  if (q) list = list.filter(({ opt }) => (opt.label || '').toLowerCase().includes(q));
  if (rlSort === 'price_asc') list.sort((a, b) => (a.opt.price || 0) - (b.opt.price || 0));
  else if (rlSort === 'price_desc') list.sort((a, b) => (b.opt.price || 0) - (a.opt.price || 0));
  return list;
}

function rlKindLabel(opt) {
  if (opt.kind === 'ipl') return 'Hazır Mekan';
  if (opt.kind === 'shell') return 'Shell';
  return 'Özel İnşa';
}

// Kart <-> harita pin'i arasına noktalı bağlantı çizgisi çizen overlay
// SVG — bu ekranın "imza" detayı: hangi kartın haritanın neresine
// karşılık geldiğini canlı olarak gösteriyor.
function rlDrawLink() {
  const overlay = document.getElementById('rlLinkOverlay');
  if (!overlay) return;
  overlay.innerHTML = '';
  if (!rlHover) return;
  const cardEl = document.querySelector(`.rl-card[data-key="${rlHover}"]`);
  const pinEl = document.querySelector(`.rl-pin[data-key="${rlHover}"]`);
  if (!cardEl || !pinEl) return;
  const oRect = overlay.getBoundingClientRect();
  const cRect = cardEl.getBoundingClientRect();
  const pRect = pinEl.getBoundingClientRect();
  const x1 = cRect.right - oRect.left, y1 = cRect.top + cRect.height / 2 - oRect.top;
  const x2 = pRect.left + pRect.width / 2 - oRect.left, y2 = pRect.top + pRect.height / 2 - oRect.top;
  const midX = (x1 + x2) / 2;
  const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
  path.setAttribute('d', `M${x1},${y1} C${midX},${y1} ${midX},${y2} ${x2},${y2}`);
  path.setAttribute('class', 'rl-link-line');
  overlay.appendChild(path);
}

function rlBuildMapSvg(pins) {
  // Artık sadece pin katmanı — harita zemini direkt <img> (bkz. renderRealtor).
  return `<svg viewBox="0 0 ${RL_MAP.w} ${RL_MAP.h}" class="rl-map-svg">${pins}</svg>`;
}

function renderRealtor() {
  clear();
  const wrap = E('div', 'rl-wrap');

  // ---- üst bar ----
  const top = E('div', 'rl-top');
  top.innerHTML = `<div class="rl-top-l">
      <img class="rl-logo" id="rlLogo" src="img/logo.jpg" alt="">
      <div><div class="rl-title">VINELAND PROPERTIES</div><div class="rl-sub">Mülk seç, satın al, kur</div></div>
    </div>`;
  const rlLogo = top.querySelector('#rlLogo');
  if (rlLogo) rlLogo.onerror = () => { rlLogo.outerHTML = `<div class="rl-badge">${icon('house')}</div>`; };
  const searchWrap = E('div', 'rl-search');
  searchWrap.innerHTML = `${icon('search')}`;
  const searchInput = E('input', 'rl-search-input');
  searchInput.placeholder = 'Mülk ara (ör. Eclipse, Villa, Depo)...';
  searchInput.value = rlSearch;
  searchInput.oninput = (e) => { rlSearch = e.target.value; renderRealtor(); };
  searchWrap.appendChild(searchInput);
  top.appendChild(searchWrap);
  const sortSel = E('select', 'rl-sort');
  sortSel.innerHTML = `<option value="default">Sıralama: Varsayılan</option>
    <option value="price_asc">Fiyat: Artan</option>
    <option value="price_desc">Fiyat: Azalan</option>`;
  sortSel.value = rlSort;
  sortSel.onchange = (e) => { rlSort = e.target.value; renderRealtor(); };
  top.appendChild(sortSel);
  const closeBtn = E('button', 'ibtn x', icon('x'));
  closeBtn.onclick = close;
  top.appendChild(closeBtn);
  wrap.appendChild(top);

  // ---- gövde: rail + grid + harita ----
  const body = E('div', 'rl-body');

  // sol filtre rayı
  const rail = E('div', 'rl-rail');
  const ptypeWrap = E('div', 'rl-rail-group');
  ptypeWrap.innerHTML = `<div class="rl-rail-eyebrow">${icon('sliders')} TÜR</div>`;
  [['all', 'Tümü'], ['home', 'Ev'], ['business', 'İşletme']].forEach(([val, label]) => {
    const b = E('button', 'rl-pill' + (rlPtype === val ? ' on' : ''), label);
    b.onclick = () => { rlPtype = val; rlCatIdx = -1; renderRealtor(); };
    ptypeWrap.appendChild(b);
  });
  rail.appendChild(ptypeWrap);

  const catWrap = E('div', 'rl-rail-group');
  catWrap.innerHTML = `<div class="rl-rail-eyebrow">${icon('house')} KATEGORİ</div>`;
  const allCatBtn = E('button', 'rl-catnav' + (rlCatIdx === -1 ? ' on' : ''),
    `<span>Tüm Kategoriler</span><small>${rlVisibleCats().reduce((n, c) => n + (c.options || []).length, 0)}</small>`);
  allCatBtn.onclick = () => { rlCatIdx = -1; renderRealtor(); };
  catWrap.appendChild(allCatBtn);
  rlVisibleCats().forEach((c) => {
    const realIdx = RC.indexOf(c);
    const b = E('button', 'rl-catnav' + (rlCatIdx === realIdx ? ' on' : ''),
      `<span>${c.label}</span><small>${(c.options || []).length}</small>`);
    b.onclick = () => { rlCatIdx = realIdx; renderRealtor(); };
    catWrap.appendChild(b);
  });
  rail.appendChild(catWrap);
  body.appendChild(rail);

  // orta: kart grid
  const main = E('div', 'rl-main');
  const list = rlFlatten();
  if (list.length === 0) {
    main.appendChild(E('div', 'rl-empty', `${icon('search')}<div>Hiç mülk bulunamadı.</div><small>Aramayı temizlemeyi dene.</small>`));
  } else {
    const grid = E('div', 'rl-grid');
    list.forEach(({ opt, cat }) => {
      const key = `${opt._catId}__${opt._optIndex}`;
      const card = E('div', 'rl-card');
      card.dataset.key = key;
      const hasCoords = !!opt.coords;
      const kindClass = opt.kind === 'ipl' ? 'fixed' : opt.kind === 'shell' ? 'shell' : 'custom';
      const placeholderIcon = icon(cat.ptype === 'business' ? 'office' : 'house');
      // ✅ BUG DÜZELTİLDİ: önceden onerror="..." bir HTML ÖZNİTELİĞİ
      // string'i içine, ikonun kendi çift-tırnaklı SVG özniteliklerini
      // (viewBox="0 0 24 24" vb.) HİÇ kaçışlamadan gömüyordum — tarayıcı
      // ilk iç tırnakta özniteliği erken kapatıp geri kalanını sayfaya
      // "sızdırıyordu" (kartlardaki o garip '''> karakterleri buydu).
      // Şimdi <img> boş placeholder ile başlıyor, hata olursa onerror'ı
      // GERÇEK bir JS fonksiyonu olarak (property ataması, HTML string
      // değil) bağlıyoruz — tıpkı logo/harita görselinde yaptığımız gibi.
      card.innerHTML = `
        <div class="rl-card-thumb ${kindClass}${opt.img ? ' has-img' : ''}">
          ${opt.img ? `<img class="rl-card-img">` : placeholderIcon}
          <span class="rl-card-kind">${rlKindLabel(opt)}</span>
        </div>
        <div class="rl-card-body">
          <div class="rl-card-name">${opt.label}</div>
          <div class="rl-card-cat">${cat.label}</div>
          <div class="rl-card-loc">${icon('pin')} ${hasCoords ? 'Haritada sabit konum' : 'Bulunduğun yere kurulur'}</div>
          <div class="rl-card-foot">
            <div class="rl-price">$${(opt.price || 0).toLocaleString('en-US')}${opt.entryFee ? `<small>+ giriş $${opt.entryFee}</small>` : ''}</div>
            <button class="rl-buy">${opt.kind ? 'Satın Al' : 'İnşa Et'}</button>
          </div>
        </div>`;
      if (opt.img) {
        const imgEl = card.querySelector('.rl-card-img');
        imgEl.onerror = () => {
          const thumb = card.querySelector('.rl-card-thumb');
          thumb.classList.remove('has-img');
          imgEl.remove();
          thumb.insertAdjacentHTML('afterbegin', placeholderIcon);
        };
        imgEl.src = `img/${opt.img}`;
      }
      card.addEventListener('mouseenter', () => { rlHover = key; rlDrawLink(); document.querySelectorAll('.rl-pin').forEach(p => p.classList.toggle('active', p.dataset.key === key)); });
      card.addEventListener('mouseleave', () => { rlHover = null; rlDrawLink(); document.querySelectorAll('.rl-pin').forEach(p => p.classList.remove('active')); });
      card.querySelector('.rl-buy').onclick = () => post('yg_realtorCreate', { catId: opt._catId, optIndex: opt._optIndex });
      grid.appendChild(card);
    });
    main.appendChild(grid);
  }
  body.appendChild(main);

  // sağ: harita paneli — SENİN yükleyeceğin gerçek harita görseli varsa
  // (html/img/map.jpg) onu gösterir, yoksa altındaki özgün soyut SVG
  // haritaya döner. Pin'ler HER İKİ durumda da (gerçek foto ya da soyut
  // harita) aynı oyun-koordinatı hesabıyla üstte duruyor.
  const mapPanel = E('div', 'rl-map-panel');
  const fixedList = list.filter(({ opt }) => !!opt.coords);
  let pinsSvg = '';
  fixedList.forEach(({ opt }) => {
    const { mx, my } = rlWorldToMap(opt.coords.x, opt.coords.y);
    const key = `${opt._catId}__${opt._optIndex}`;
    pinsSvg += `<g class="rl-pin" data-key="${key}" transform="translate(${mx},${my})">
        <path class="rl-pin-shape" d="M0,0 C-3,-10 -14,-14 -14,-24 A14,14 0 1,1 14,-24 C14,-14 3,-10 0,0 Z"/>
        <circle class="rl-pin-hole" cx="0" cy="-24" r="6"/>
      </g>`;
  });
  mapPanel.innerHTML = `<div class="rl-map-head">${icon('crosshair')} <span>Mülk Haritası</span><small>${fixedList.length} sabit konum</small></div>
    <div class="rl-map-frame" id="rlMapFrame">
      <img class="rl-map-photo" id="rlMapPhoto" src="img/map.jpg" alt="harita">
      ${rlBuildMapSvg(pinsSvg)}
      <svg id="rlLinkOverlay" class="rl-link-overlay"></svg>
    </div>
    <div class="rl-map-legend">
      <div><span class="rl-dot fixed"></span> Sabit konum (haritada)</div>
      <div><span class="rl-dot shell"></span> Bulunduğun yere kurulur</div>
    </div>`;
  body.appendChild(mapPanel);
  const mapPhoto = document.getElementById('rlMapPhoto');
  const mapFrame = document.getElementById('rlMapFrame');
  if (mapPhoto) {
    mapPhoto.onerror = () => {
      const dbg = document.createElement('div');
      dbg.className = 'rl-map-debug';
      dbg.textContent = `Yüklenemedi: img/map.jpg — html/img/README.txt'e bak`;
      mapFrame.appendChild(dbg);
    };
  }

  wrap.appendChild(body);
  root.appendChild(wrap);

  list.forEach(({ opt }) => {
    if (!opt.coords) return;
    const key = `${opt._catId}__${opt._optIndex}`;
    const pinEl = document.querySelector(`.rl-pin[data-key="${key}"]`);
    if (pinEl) pinEl.addEventListener('mouseenter', () => { rlHover = key; rlDrawLink(); document.querySelectorAll('.rl-card').forEach(c => c.classList.toggle('rl-card-active', c.dataset.key === key)); });
    if (pinEl) pinEl.addEventListener('mouseleave', () => { rlHover = null; rlDrawLink(); document.querySelectorAll('.rl-card').forEach(c => c.classList.remove('rl-card-active')); });
  });
}

/* ============================================================
   MEKAN BİLGİSİ (kapıdaki "Mekan Bilgisi" target seçeneği)
   ============================================================ */
function renderPropertyInfo(d) {
  clear();
  const wrap = E('div', 'wrap'); wrap.style.width = '420px';
  wrap.appendChild(topBar('MEKAN BİLGİSİ', close));
  const body = E('div', 'body');
  const statusLine = d.owned ? (d.locked ? '🔒 Kilitli' : '🔓 Açık') : `Satılık • $${d.price || 0}`;
  body.innerHTML = `<div class="card">
    <h3>${d.label || 'Mekan'}</h3>
    <div class="lbl" style="margin-top:12px">Tür</div>
    <div class="ld" style="font-size:14px">${d.type === 'business' ? 'İşletme' : 'Ev'}</div>
    <div class="lbl" style="margin-top:12px">Durum</div>
    <div class="ld" style="font-size:14px">${statusLine}</div>
    ${d.type === 'business' ? `<div class="lbl" style="margin-top:12px">Giriş Ücreti</div><div class="ld" style="font-size:14px;color:var(--green)">$${d.entry_fee || 0}</div>` : ''}
    ${d.description ? `<div class="lbl" style="margin-top:12px">Açıklama</div><div class="ld" style="font-size:13px">${d.description}</div>` : ''}
  </div>`;
  wrap.appendChild(body);
  root.appendChild(wrap);
}

/* ============================================================
   BUY popup (kapı dışı)
   ============================================================ */
function openBuy(d) {
  clear();
  const p = d.property || {};
  const wrap = E('div', 'wrap'); wrap.style.width = '420px';
  wrap.appendChild(topBar('SATIN AL', close));
  const body = E('div', 'body');
  body.innerHTML = `<div class="card"><h3>${p.label || 'Mekan'}</h3>
    <div class="ld" style="color:var(--text2);font-size:14px">${p.type === 'business' ? 'İşletme' : 'Ev'} • Fiyat: <b style="color:var(--green)">$${p.price || 0}</b></div></div>`;
  wrap.appendChild(body);
  const foot = E('div', 'foot');
  const c = E('button', 'fbtn', 'Vazgeç'); c.onclick = close;
  const b = E('button', 'fbtn primary', 'Satın Al'); b.onclick = () => post('yg_buy', { propertyId: p.id }).then(close);
  foot.append(c, b); wrap.appendChild(foot);
  root.appendChild(wrap);
}

/* ============================================================
   BUILD CATALOG + OBJECT MANAGER — "Dekorasyon Menüsü" tasarımı
   (referans ekran görüntüsünün düzeni, emlakçı ekranının altın/teal
   lacivert paletiyle). NOT: referanstaki "Qty"/fiyat etiketleri bizim
   dekor objelerinde YOK (bunlar ücretsiz yerleştiriliyor) — sahte veri
   uydurmadım, sadece gerçekten var olan alanları (isim, model kodu)
   gösteriyorum. Alttaki kontrol çubuğu da gerçek gizmo tuşlarını
   yansıtıyor (client/gizmo.lua) — referanstaki gibi tıklanabilir sahte
   "Döndür/Taşı" butonları değil, çünkü bizim sistemde o işlemler
   native gizmo (W/R/S tuşları) ile yapılıyor, NUI'den değil.
   ============================================================ */
let catalog = [], decorCat = -1, decorCount = 0, decorLimit = 300;

function bdTabs(activeTab) {
  const tabs = E('div', 'bd-tabs');
  const t1 = E('button', 'bd-tab' + (activeTab === 'catalog' ? ' on' : ''), `${icon('box')} Katalog`);
  t1.onclick = () => renderDecorCatalog();
  const t3 = E('button', 'bd-tab' + (activeTab === 'build' ? ' on' : ''), `${icon('brush')} Build`);
  t3.onclick = () => renderBuildTab();
  const t2 = E('button', 'bd-tab' + (activeTab === 'manage' ? ' on' : ''), `${icon('sliders')} Yerleştirilenler`);
  t2.onclick = () => openObjManager();
  tabs.append(t1, t3, t2);
  return tabs;
}

// Build modu SADECE bu 2 kategoriyi kullanıyor — Config.StructureCategories
// ile aynı liste (client/gizmo.lua'daki isStructureModel mantığıyla tutarlı).
const BUILD_CATEGORIES = ['Ev İnşa (Duvar & Zemin)'];
let buildCat = -1; // -1 = tüm yapı kategorileri

function renderBuildTab() {
  clear();
  const wrap = E('div', 'bd-wrap bd-compact bd-compact-norail');

  const top = E('div', 'bd-top');
  top.innerHTML = `<div class="bd-top-l"><div class="bd-badge">${icon('brush')}</div>
      <div><div class="bd-title">İNŞA MODU</div></div></div>`;
  const decorBtn = E('button', 'ibtn', icon('box'));
  decorBtn.setAttribute('data-tip', 'Dekor Menüsü');
  decorBtn.onclick = () => renderDecorCatalog();
  top.appendChild(decorBtn);
  const manageBtn = E('button', 'ibtn', icon('sliders'));
  manageBtn.setAttribute('data-tip', 'Yerleştirilenler');
  manageBtn.onclick = openObjManager;
  top.appendChild(manageBtn);
  const closeBtn = E('button', 'ibtn x', icon('x'));
  closeBtn.onclick = close;
  top.appendChild(closeBtn);
  wrap.appendChild(top);

  const body = E('div', 'bd-body');
  const main = E('div', 'bd-main');

  const sb = E('div', 'bd-search');
  sb.innerHTML = icon('search');
  const search = E('input', 'bd-search-input'); search.placeholder = 'Yapı parçası ara...';
  sb.appendChild(search); main.appendChild(sb);

  // ✅ EKLENDİ: özel model kodu ile de Build modu başlatılabiliyor.
  main.appendChild(E('div', 'bd-cat-eyebrow', 'ÖZEL MODEL İLE BAŞLAT'));
  const cust = E('div', 'bd-custrow');
  const ci = E('input', 'bd-search-input'); ci.placeholder = 'Model kodu girin...';
  const cadd = E('button', 'bd-mini', 'BAŞLAT');
  cadd.onclick = () => { const m = ci.value.trim(); if (m) post('startBuildMode', { model: m }); };
  ci.addEventListener('keydown', e => { if (e.key === 'Enter') cadd.click(); });
  cust.append(ci, cadd); main.appendChild(cust);

  // NOT: tek yapı kategorisi olduğu için (Ev İnşa) kategori seçici yok —
  // dekor menüsünden farklı olarak burada seçilecek başka kategori zaten yok.
  const note = E('div', 'bd-buildnote');
  note.textContent = 'Bir parça seç → kamera serbestleşir (freecam), otomatik yapışır.';
  main.appendChild(note);

  const gridWrap = E('div', 'bd-gridwrap');
  const grid = E('div', 'bd-grid'); gridWrap.appendChild(grid); main.appendChild(gridWrap);

  function draw() {
    const q = (search.value || '').toLowerCase(); grid.innerHTML = '';
    const buildCats = catalog.filter(c => BUILD_CATEGORIES.includes(c.category));
    const items = [];
    buildCats.forEach(c => c && (c.items || []).forEach(it => {
      if (q && !(it.label || '').toLowerCase().includes(q) && !(it.model || '').toLowerCase().includes(q)) return;
      items.push([c, it]);
    }));
    if (items.length === 0) {
      grid.appendChild(E('div', 'bd-empty-soft', `${icon('search')}<span>Bir şey bulamadım</span><small>Farklı bir arama dene ya da kategoriyi değiştir</small>`));
      return;
    }

    // ✅ BUG DÜZELTİLDİ ("menü açılınca kasıyor"): eskiden onlarca kart
    // TEK BİR JS turunda (senkron) DOM'a ekleniyordu — çok sayıda parça
    // olan kataloglarda (200+ duvar/zemin gibi) bu, menü açılırken
    // gözle görülür bir donmaya sebep oluyordu. Artık kartları KÜÇÜK
    // PARÇALAR (24'er) halinde, tarayıcının bir sonraki çizim karesini
    // (requestAnimationFrame) bekleyerek ekliyoruz — arayüz donmadan,
    // parça parça (gözle fark edilmeyecek kadar hızlı) doluyor.
    let i = 0;
    const CHUNK = 24;
    function addChunk() {
      const frag = document.createDocumentFragment();
      const end = Math.min(i + CHUNK, items.length);
      for (; i < end; i++) {
        const [c, it] = items[i];
        const card = E('div', 'bd-card');
        card.innerHTML = `<div class="bd-card-thumb">
            <img src="img/${encodeURIComponent(it.model)}.webp" alt="" loading="lazy" decoding="async"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';">
            <div class="bd-card-thumb-icon">${icon(categoryIcon((c.category || '') + ' ' + (it.label || '')))}</div>
          </div>
          <div class="bd-card-body">
            <div class="bd-card-name">${it.label || it.model}</div>
          </div>`;
        const place = E('button', 'bd-place', `${icon('plus')} BAŞLAT`);
        place.onclick = () => post('startBuildMode', { model: it.model });
        let hoverTimer = null;
        const startPreview = () => { hoverTimer = setTimeout(() => post('previewProp', { model: it.model }), 120); };
        const stopPreview = () => { clearTimeout(hoverTimer); post('previewPropClear'); };
        card.addEventListener('mouseenter', startPreview);
        card.addEventListener('mouseleave', stopPreview);
        card.querySelector('.bd-card-body').appendChild(place);
        frag.appendChild(card);
      }
      grid.appendChild(frag);
      if (i < items.length) requestAnimationFrame(addChunk);
    }
    addChunk();
  }
  let searchDebounce = null;
  search.oninput = () => { clearTimeout(searchDebounce); searchDebounce = setTimeout(draw, 180); };
  draw();

  body.appendChild(main);
  wrap.appendChild(body);
  root.appendChild(wrap);
}

function renderDecorCatalog(data) {
  if (data && Array.isArray(data.catalog)) catalog = data.catalog;
  if (data && typeof data.count === 'number') decorCount = data.count;
  if (data && typeof data.limit === 'number') decorLimit = data.limit;
  clear();
  const wrap = E('div', 'bd-wrap bd-compact');

  const top = E('div', 'bd-top');
  top.innerHTML = `<div class="bd-top-l"><div class="bd-badge">${icon('brush')}</div>
      <div><div class="bd-title">DEKOR MENÜSÜ</div></div></div>`;
  const manageBtn = E('button', 'ibtn', icon('sliders'));
  manageBtn.setAttribute('data-tip', 'Yerleştirilenler');
  manageBtn.onclick = openObjManager;
  top.appendChild(manageBtn);
  const buildBtn = E('button', 'ibtn', icon('cog'));
  buildBtn.setAttribute('data-tip', 'İnşa Modu');
  buildBtn.onclick = renderBuildTab;
  top.appendChild(buildBtn);
  const closeBtn = E('button', 'ibtn x', icon('x'));
  closeBtn.onclick = close;
  top.appendChild(closeBtn);
  wrap.appendChild(top);

  const body = E('div', 'bd-body');

  // ✅ "Ev İnşa (Duvar & Zemin)" artık AYRI "Build" sekmesinde (freecam+
  // grid ile) — burada (normal Katalog'da) tekrar gösterilmiyor, karışıklık olmasın diye.
  const nonBuildCats = catalog.filter(c => !BUILD_CATEGORIES.includes(c.category));

  // ✅ EKLENDİ: kompakt kategori şeridi — referanstaki gibi solda, ayrı
  // tonda, ikon+isim+sayı ile. Dropdown'dan geri döndük çünkü referans
  // net şekilde bunu gösteriyordu.
  const rail = E('div', 'bd-compact-rail');
  const allBtn = E('button', 'bd-compact-catbtn' + (decorCat < 0 ? ' on' : ''),
    `${icon('box')}<span>Tümü</span><small>${nonBuildCats.reduce((a, c) => a + ((c.items || []).length), 0)}</small>`);
  allBtn.onclick = () => { decorCat = -1; renderDecorCatalog(); };
  rail.appendChild(allBtn);
  nonBuildCats.forEach((c) => {
    const i = catalog.indexOf(c);
    const b = E('button', 'bd-compact-catbtn' + (decorCat === i ? ' on' : ''),
      `${icon(categoryIcon(c.category))}<span>${c.category || 'Kategori'}</span><small>${(c.items || []).length}</small>`);
    b.onclick = () => { decorCat = i; renderDecorCatalog(); };
    rail.appendChild(b);
  });
  body.appendChild(rail);

  const main = E('div', 'bd-main');
  const sb = E('div', 'bd-search');
  sb.innerHTML = icon('search');
  const search = E('input', 'bd-search-input'); search.placeholder = 'Mobilya Ara...';
  sb.appendChild(search); main.appendChild(sb);

  main.appendChild(E('div', 'bd-cat-eyebrow', 'ÖZEL PROP GİRİŞİ'));
  const cust = E('div', 'bd-custrow');
  const ci = E('input', 'bd-search-input'); ci.placeholder = 'Prop ismi girin...';
  const cadd = E('button', 'bd-mini', 'EKLE');
  cadd.onclick = () => { const m = ci.value.trim(); if (m) post('spawnByModel', { model: m }); };
  ci.addEventListener('keydown', e => { if (e.key === 'Enter') cadd.click(); });
  cust.append(ci, cadd); main.appendChild(cust);

  const gridWrap = E('div', 'bd-gridwrap');
  const grid = E('div', 'bd-grid'); gridWrap.appendChild(grid); main.appendChild(gridWrap);

  function draw() {
    const q = (search.value || '').toLowerCase(); grid.innerHTML = '';
    const cats = decorCat < 0 ? nonBuildCats : [catalog[decorCat]];
    const items = [];
    cats.forEach(c => c && (c.items || []).forEach(it => {
      if (q && !(it.label || '').toLowerCase().includes(q) && !(it.model || '').toLowerCase().includes(q)) return;
      items.push([c, it]);
    }));
    if (items.length === 0) {
      grid.appendChild(E('div', 'bd-empty-soft', `${icon('search')}<span>Bir şey bulamadım</span><small>Farklı bir arama dene ya da kategoriyi değiştir</small>`));
      return;
    }

    // ✅ BUG DÜZELTİLDİ ("menü açılınca kasıyor") — Build sekmesindeki
    // AYNI çözüm: kartları küçük parçalar halinde, bir sonraki çizim
    // karesini bekleyerek ekliyoruz, arayüz donmuyor.
    let i = 0;
    const CHUNK = 24;
    function addChunk() {
      const frag = document.createDocumentFragment();
      const end = Math.min(i + CHUNK, items.length);
      for (; i < end; i++) {
        const [c, it] = items[i];
        const card = E('div', 'bd-card');
        // ✅ görsel otomatik eşleştirme — img/{model}.webp var mı diye
        // dener, yoksa (onerror) eski ikona geri döner.
        card.innerHTML = `<div class="bd-card-thumb">
            <img src="img/${encodeURIComponent(it.model)}.webp" alt="" loading="lazy" decoding="async"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';">
            <div class="bd-card-thumb-icon">${icon(categoryIcon((c.category || '') + ' ' + (it.label || '')))}</div>
          </div>
          <div class="bd-card-body">
            <div class="bd-card-name">${it.label || it.model}</div>
          </div>`;
        const place = E('button', 'bd-place', `${icon('plus')} YERLEŞTİR`);
        place.onclick = () => post('spawn', { model: it.model }).then(r => {
          if (r && r.ok !== false) toast(`✓ ${it.label || it.model} yerleştirildi.`);
          else toast('Yerleştirilemedi.');
        });
        // Fareyle gelince, objenin GERÇEK 3D modelini oyuncunun yanında
        // gösteren önizleme — sadece bizde görünüyor, hiçbir şey kaydedilmiyor.
        let hoverTimer = null;
        const startPreview = () => { hoverTimer = setTimeout(() => post('previewProp', { model: it.model }), 120); };
        const stopPreview = () => { clearTimeout(hoverTimer); post('previewPropClear'); };
        card.addEventListener('mouseenter', startPreview);
        card.addEventListener('mouseleave', stopPreview);
        card.querySelector('.bd-card-body').appendChild(place);
        frag.appendChild(card);
      }
      grid.appendChild(frag);
      if (i < items.length) requestAnimationFrame(addChunk);
    }
    addChunk();
  }
  let searchDebounce = null;
  search.oninput = () => { clearTimeout(searchDebounce); searchDebounce = setTimeout(draw, 180); };
  draw();
  body.appendChild(main);
  wrap.appendChild(body);

  root.appendChild(wrap);
}

async function openObjManager() {
  clear();
  const wrap = E('div', 'bd-wrap bd-compact bd-compact-norail');
  const top = E('div', 'bd-top');
  top.innerHTML = `<div class="bd-top-l"><div class="bd-badge">${icon('sliders')}</div>
      <div><div class="bd-title">YERLEŞTİRİLENLER</div></div></div>`;
  const decorBtn = E('button', 'ibtn', icon('box'));
  decorBtn.setAttribute('data-tip', 'Dekor Menüsü');
  decorBtn.onclick = () => renderDecorCatalog();
  top.appendChild(decorBtn);
  const buildBtn = E('button', 'ibtn', icon('cog'));
  buildBtn.setAttribute('data-tip', 'İnşa Modu');
  buildBtn.onclick = renderBuildTab;
  top.appendChild(buildBtn);
  const closeBtn = E('button', 'ibtn x', icon('x'));
  closeBtn.onclick = close;
  top.appendChild(closeBtn);
  wrap.appendChild(top);

  const body = E('div', 'bd-body');
  const main = E('div', 'bd-main');
  main.appendChild(E('div', 'empty', 'Yükleniyor...'));
  body.appendChild(main);
  wrap.appendChild(body);
  root.appendChild(wrap);

  const res = await post('getObjectList', {});
  const objs = res.objects || [];
  main.innerHTML = '';

  const toolbar = E('div', 'bd-toolbar-compact');
  const undoBtn = E('button', 'bd-mini', `${icon('x')} Geri Al`);
  undoBtn.onclick = async () => {
    const r = await post('undoLast', {});
    if (r && r.ok) { toast('Geri alındı.'); openObjManager(); } else toast('Geri alınacak işlem yok.');
  };
  const radiusWrap = E('div', 'bd-radiuswrap');
  const radiusInput = E('input', 'bd-search-input'); radiusInput.type = 'number'; radiusInput.placeholder = 'Yarıçap (m)'; radiusInput.value = '3';
  const nearBtn = E('button', 'bd-mini danger', 'Yakındakileri Sil');
  nearBtn.onclick = () => {
    const rad = Number(radiusInput.value) || 3;
    modalConfirm(`${rad}m içindeki TÜM objeler silinecek. Emin misin?`, async () => {
      const r = await post('deleteNearby', { radius: rad, objects: objs });
      toast(`${(r && r.count) || 0} obje silindi.`);
      openObjManager();
    });
  };
  radiusWrap.append(radiusInput, nearBtn);
  toolbar.append(undoBtn, radiusWrap);
  main.appendChild(toolbar);

  const list = E('div', 'bd-objlist-compact');
  objs.forEach(o => {
    const r = E('div', 'bd-objrow-compact');
    const distTxt = (typeof o.distance === 'number' && o.distance < 9000) ? `${o.distance.toFixed(1)}m` : '';
    r.innerHTML = `<div class="bd-objicon">${icon('box')}</div>
      <div class="bd-objinfo"><div class="bd-objname">${o.model}</div><div class="bd-objmeta">ID: ${o.id}${distTxt ? ' • ' + distTxt : ''}</div></div>`;
    const acts = E('div', 'bd-objacts-compact');
    const dup = E('button', 'bd-mini-sm', 'Çoğalt');
    dup.onclick = () => { post('duplicateObject', { id: o.id, model: o.model, coords: o.coords, rotation: o.rotation }); close(); };
    const ed = E('button', 'bd-mini-sm', 'Düzenle');
    ed.onclick = () => { post('editObject', { id: o.id, model: o.model }); close(); };
    const dl = E('button', 'bd-mini-sm danger', 'Sil');
    dl.onclick = async () => { await post('deleteObject', { id: o.id, model: o.model, coords: o.coords, rotation: o.rotation }); openObjManager(); };
    acts.append(dup, ed, dl);
    r.appendChild(acts);
    list.appendChild(r);
  });
  if (objs.length === 0) list.appendChild(E('div', 'empty', 'Bu mekanda obje yok.'));
  main.appendChild(list);
}

/* ============================================================
   MESSAGE BUS
   ============================================================ */
window.addEventListener('message', e => {
  const d = e.data || {};
  switch (d.action) {
    case 'openManagement': return openManagement(d.data || {});
    case 'openInfo': return renderPropertyInfo(d.data || {});
    case 'openRealtor': return openRealtor(d.data || {});
    case 'showLoading': return showLoadingOverlay();
    case 'hideLoading': return hideLoadingOverlay();
    case 'openMyKeys': return openMyKeys(d.data || {});
    case 'openBuy': return openBuy(d.data || {});
    case 'open':
    case 'openDecor': return renderDecorCatalog(d);
    case 'openManage': return openObjManager();
    case 'refreshManage': return openObjManager();
    case 'close': return clear();
    case 'notify': return toast(d.message || '');
  }
});
function openMyKeys(d) {
  clear();
  const wrap = E('div', 'wrap'); wrap.appendChild(topBar('ANAHTARLARIM', close));
  const body = E('div', 'body'); const list = E('div', 'list');
  (d.list || []).forEach(p => {
    const r = E('div', 'listrow');
    r.innerHTML = `<div class="li">${icon('key')}</div><div class="lc"><div class="lt">${p.label || 'Mekan'}</div><div class="ld">${Number(p.is_owner) ? 'Sahip' : 'Anahtar'}</div></div>`;
    const go = E('button', 'lact', 'Konum'); go.onclick = () => post('yg_gotoMyKey', { propertyId: p.id });
    r.appendChild(go); list.appendChild(r);
  });
  if ((d.list || []).length === 0) list.appendChild(E('div', 'empty', 'Hiç anahtarın yok.'));
  body.appendChild(list); wrap.appendChild(body); root.appendChild(wrap);
}

// Gizmo artık tamamen native (client/gizmo.lua) — NUI/SVG çizimi tümüyle kaldırıldı.
document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });
