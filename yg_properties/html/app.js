const app = document.getElementById('app');
const titleEl = document.getElementById('title');
const closeBtn = document.getElementById('closeBtn');

const manageBtn = document.getElementById('manageBtn');
const catalogBtn = document.getElementById('catalogBtn');

const catalogView = document.getElementById('catalogView');
const manageView = document.getElementById('manageView');

const content = document.getElementById('content');
const search = document.getElementById('search');
const modelInput = document.getElementById('modelInput');
const spawnModelBtn = document.getElementById('spawnModelBtn');

const refreshBtn = document.getElementById('refreshBtn');
const manageList = document.getElementById('manageList');

let catalog = [];

// Sayfa ilk yüklendiğinde kapalı başlasın
app.classList.add('hidden');

// Lua ile iletişim kuran ana fonksiyon
function post(name, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  }).then(r => r.json().catch(() => ({})));
}

// Menü Açma/Kapama
function setOpen(open) {
  app.classList.toggle('hidden', !open);
  if (!open) {
    // Kapatıldığında temizlik yap ki tekrar açıldığında eski veriler kalmasın
    search.value = '';
    modelInput.value = '';
  }
}

// Katalog Görünümüne Geç
function showCatalog() {
  titleEl.textContent = 'Build Catalog';
  catalogView.classList.remove('hidden');
  manageView.classList.add('hidden');
  catalogBtn.classList.add('hidden'); // Katalogdayken butonu gizle
  manageBtn.classList.remove('hidden'); // Objelerim butonu görünsün
}

// Obje Yönetim Görünümüne Geç
function showManage() {
  titleEl.textContent = 'Mekandaki Objeler';
  catalogView.classList.add('hidden');
  manageView.classList.remove('hidden');
  manageBtn.classList.add('hidden'); // Objelerimdeyken butonu gizle
  catalogBtn.classList.remove('hidden'); // Katalog butonu görünsün
  refreshManage(); // Listeyi güncelle
}

// Katalog Listesini Oluştur (Search destekli)
function renderCatalog() {
  const q = (search.value || '').toLowerCase();
  content.innerHTML = '';

  for (const cat of catalog) {
    const items = (cat.items || []).filter(it => {
      const label = (it.label || '').toLowerCase();
      const model = (it.model || '').toLowerCase();
      return !q || label.includes(q) || model.includes(q);
    });

    if (items.length === 0) continue;

    const box = document.createElement('div');
    box.className = 'category';
    box.innerHTML = `<div style="color:var(--accent); font-weight:800; font-size:11px; margin-bottom:10px; text-transform:uppercase; letter-spacing:1px;">${cat.category || 'Kategori'}</div>`;

    const grid = document.createElement('div');
    grid.className = 'items';

    for (const it of items) {
      const el = document.createElement('div');
      el.className = 'item';
      el.innerHTML = `<span class="label">${it.label || it.model}</span><span class="model">${it.model}</span>`;
      el.addEventListener('click', () => {
        post('spawn', { model: it.model });
        setOpen(false);
        post('close');
      });
      grid.appendChild(el);
    }

    box.appendChild(grid);
    content.appendChild(box);
  }
}

// Liste Satırı Tasarımı (Manage List)
function rowHtml(o) {
  return `
    <div class="listRow" data-id="${o.id}">
      <div class="info">
        <b>${o.model}</b>
        <small>ID: ${o.id}</small>
      </div>
      <div class="actions">
        <button class="btn btnSmall" data-action="edit"><i class="fas fa-edit"></i> Düzenle</button>
        <button class="btn btnSmall btnDanger" data-action="delete"><i class="fas fa-trash"></i> Sil</button>
      </div>
    </div>
  `;
}

// Mekandaki Objeleri Güncelle
async function refreshManage() {
  manageList.innerHTML = '<div style="text-align:center; padding:20px; color:var(--muted);">Yükleniyor...</div>';
  const res = await post('getObjectList', {});
  
  if (!res || !res.ok) {
    manageList.innerHTML = '<div style="text-align:center; padding:20px; color:var(--danger);">Liste alınamadı (Lua hatası).</div>';
    return;
  }

  const objs = Array.isArray(res.objects) ? res.objects : [];
  if (objs.length === 0) {
    manageList.innerHTML = '<div style="text-align:center; padding:40px; color:var(--muted);">Bu mekanda henüz hiç obje yok.</div>';
    return;
  }

  manageList.innerHTML = objs.map(rowHtml).join('');

  // Butonlara tıklama işlevlerini bağla
  manageList.querySelectorAll('.listRow').forEach((row) => {
    row.addEventListener('click', async (e) => {
      const btn = e.target.closest('button');
      if (!btn) return;

      const id = Number(row.getAttribute('data-id'));
      const action = btn.getAttribute('data-action');

      if (action === 'delete') {
        await post('deleteObject', { id });
        refreshManage(); // Sildikten sonra listeyi tazele
      }

      if (action === 'edit') {
        post('editObject', { id });
        setOpen(false); // Düzenleme modunda UI'ı kapat
        post('close');
      }
    });
  });
}

// NUI Mesaj Dinleyici
window.addEventListener('message', (e) => {
  const data = e.data;
  if (!data || !data.action) return;

  if (data.action === 'open') {
    catalog = Array.isArray(data.catalog) ? data.catalog : [];
    setOpen(true);
    showCatalog();
    renderCatalog();
  }

  if (data.action === 'close') setOpen(false);

  if (data.action === 'openManage') {
    setOpen(true);
    showManage();
  }

  if (data.action === 'refreshManage') {
    refreshManage();
  }
});

// Event Listeners
closeBtn.addEventListener('click', () => post('close'));
search.addEventListener('input', renderCatalog);
manageBtn.addEventListener('click', showManage);
catalogBtn.addEventListener('click', showCatalog);
refreshBtn.addEventListener('click', refreshManage);

spawnModelBtn.addEventListener('click', () => {
  const model = (modelInput.value || '').trim();
  if (!model) return;
  post('spawnByModel', { model });
  setOpen(false);
  post('close');
});