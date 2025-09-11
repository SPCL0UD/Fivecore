let visible = false;
let selected = { owner: null, slot: null, item: null };
let playerCache = [];
let otherCache  = [];
let gloveCache  = [];
let trunkCache  = [];
let nearbyPlayers = [];
let selectedNearby = null;

// Mensajes desde Lua
window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'toggleInventory') {
    visible = !visible;
    document.getElementById('inventory').classList.toggle('hidden', !visible);
  }
  if (data.action === 'setInventory') {
    // Inventarios
    playerCache = Array.isArray(data.player) ? data.player : [];
    otherCache  = Array.isArray(data.other)  ? data.other  : [];
    // Meta
    setPlayerMeta(data.meta || {});
    // Si el meta habla de vehículo, renderizar labels y panel vehículo
    setVehicleMeta(data.meta || {});
    // Render base
    renderInventory('playerInventory', playerCache, 'player');
    renderInventory('otherInventory', otherCache, 'other');
  }
  if (data.action === 'setVehicleInv') {
    gloveCache = Array.isArray(data.glove) ? data.glove : [];
    trunkCache = Array.isArray(data.trunk) ? data.trunk : [];
    renderInventory('gloveInventory', gloveCache, 'glove');
    renderInventory('trunkInventory', trunkCache, 'trunk');
  }
  if (data.action === 'setNearby') {
    nearbyPlayers = Array.isArray(data.players) ? data.players : [];
    renderNearbyList(nearbyPlayers);
  }
});

// Tabs principales
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById(btn.dataset.tab).classList.add('active');
    // Pedidos contextuales
    if (btn.dataset.tab === 'tab-vehicle') {
      fetch(`https://${GetParentResourceName()}/requestVehicleInv`, { method:'POST' });
    }
    if (btn.dataset.tab === 'tab-nearby') {
      fetch(`https://${GetParentResourceName()}/requestNearby`, { method:'POST' });
    }
  });
});

// Vehículo: subtabs
document.querySelectorAll('.veh-tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.veh-tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.veh-panel').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById(btn.dataset.tab).classList.add('active');
  });
});

function renderInventory(containerId, items, ownerType) {
  const container = document.getElementById(containerId);
  container.innerHTML = '';
  items.forEach((item, idx) => {
    const slot = document.createElement('div');
    slot.className = 'slot';
    slot.dataset.owner = ownerType;
    slot.dataset.slot = idx;
    slot.innerHTML = `
      <div class="slot-number">${idx + 1}</div>
      <img src="images/${item.name}.png" alt="${item.label}" onerror="this.src='images/_default.png'">
      <div class="count">x${item.count}</div>
    `;
    slot.addEventListener('click', () => selectSlot(ownerType, idx, item));
    slot.addEventListener('mouseenter', (ev) => showTooltip(item, ev.clientX, ev.clientY));
    slot.addEventListener('mouseleave', hideTooltip);
    container.appendChild(slot);
  });
  refreshSelection();
}

function selectSlot(owner, slotIndex, item) {
  selected = { owner, slot: slotIndex, item };
  refreshSelection(); refreshActions();
}

function refreshSelection() {
  document.querySelectorAll('.slot').forEach(el => el.classList.remove('selected'));
  if (selected.owner && selected.slot != null) {
    const id = selected.owner === 'player' ? 'playerInventory'
           : selected.owner === 'other'  ? 'otherInventory'
           : selected.owner === 'glove'  ? 'gloveInventory'
           : selected.owner === 'trunk'  ? 'trunkInventory'
           : null;
    if (!id) return;
    const grid = document.getElementById(id);
    const cell = grid && grid.querySelector(`.slot[data-slot="${selected.slot}"]`);
    if (cell) cell.classList.add('selected');
  }
}

function refreshActions() {
  const hasSel = !!selected.item && selected.owner === 'player';
  document.getElementById('useBtn').disabled   = !hasSel;
  document.getElementById('dropBtn').disabled  = !hasSel;
  document.getElementById('splitBtn').disabled = !hasSel || (selected.item && selected.item.count < 2);
}

function showTooltip(item, x, y) {
  const tip = document.getElementById('itemTooltip');
  tip.querySelector('#tooltipName').textContent = item.label || item.name;
  tip.querySelector('#tooltipDesc').textContent = item.description || '';
  tip.querySelector('#tooltipWeight').textContent = (item.weight || 0).toFixed(2);
  tip.querySelector('#tooltipStack').textContent = item.stack === false ? 'No stackeable' : 'Stackeable';
  tip.style.left = (x + 12) + 'px';
  tip.style.top  = (y + 12) + 'px';
  tip.classList.remove('hidden');
}
function hideTooltip(){ document.getElementById('itemTooltip').classList.add('hidden'); }

function setPlayerMeta(meta){
  document.getElementById('playerName').textContent   = meta.name  || 'Jugador';
  document.getElementById('playerJob').textContent    = meta.job   || 'Trabajo';
  document.getElementById('playerCash').textContent   = meta.cash  ?? 0;
  document.getElementById('playerBank').textContent   = meta.bank  ?? 0;
  document.getElementById('playerCrypto').textContent = meta.crypto?? 0;
  const weight = Number(meta.weight || 0);
  const maxW   = Number(meta.maxWeight || 0);
  const pct = maxW > 0 ? Math.min(100, Math.round((weight / maxW) * 100)) : 0;
  document.getElementById('weightFill').style.width = pct + '%';
  document.getElementById('weightText').textContent = `${weight.toFixed(2)} / ${maxW.toFixed(2)} kg`;
}

function setVehicleMeta(meta){
  document.getElementById('vehPlate').textContent = meta.vehPlate || '—';
  document.getElementById('vehSeat').textContent  = meta.vehSeat  ?? '—';
  document.getElementById('vehState').textContent = meta.inVehicle ? 'Dentro' : 'Fuera';
  const otherLabel = document.getElementById('otherLabel');
  otherLabel.textContent = meta.inVehicle ? 'Guantera / Baúl' : 'Otro inventario';
}

// Búsqueda
document.getElementById('searchPlayer').addEventListener('input', () => filterGrid('searchPlayer','playerInventory',playerCache,'player'));
document.getElementById('searchOther').addEventListener('input', () => filterGrid('searchOther','otherInventory',otherCache,'other'));
document.getElementById('searchNearby').addEventListener('input', () => {
  const q = (document.getElementById('searchNearby').value||'').toLowerCase();
  const filtered = nearbyPlayers.filter(p => (p.name||'').toLowerCase().includes(q) || String(p.id).includes(q));
  renderNearbyList(filtered);
});
function filterGrid(inputId, gridId, cache, owner){
  const q = (document.getElementById(inputId).value || '').toLowerCase();
  const filtered = cache.filter(it => (it.label || it.name || '').toLowerCase().includes(q));
  renderInventory(gridId, filtered, owner);
}

// Cerrar
document.getElementById('closeBtn').addEventListener('click', () => {
  visible = false;
  document.getElementById('inventory').classList.add('hidden');
  fetch(`https://${GetParentResourceName()}/closeInventory`, { method: 'POST' });
});

// Acciones rápidas de inventario
document.getElementById('useBtn').addEventListener('click', () => {
  if (!selected.item || selected.owner !== 'player') return;
  fetch(`https://${GetParentResourceName()}/useItem`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ owner:'player', slot:selected.slot })
  });
});
document.getElementById('dropBtn').addEventListener('click', () => {
  if (!selected.item || selected.owner !== 'player') return;
  const amount = prompt('Cantidad a tirar:', '1'); if (!amount) return;
  fetch(`https://${GetParentResourceName()}/dropItem`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ owner:'player', slot:selected.slot, count: Number(amount) })
  });
});
document.getElementById('splitBtn').addEventListener('click', () => {
  if (!selected.item || selected.owner !== 'player') return;
  const half = Math.floor(selected.item.count/2);
  const amount = prompt('Cantidad a dividir:', String(half>0?half:1)); if (!amount) return;
  fetch(`https://${GetParentResourceName()}/moveItem`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ from:selected.slot, toType:'player', to:null, count:Number(amount) })
  });
});

// Vehículo: controles
document.querySelectorAll('.veh-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const door = btn.dataset.door;
    if (door) {
      fetch(`https://${GetParentResourceName()}/vehDoor`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ door }) });
      return;
    }
    if (btn.id === 'vehCruise')  fetch(`https://${GetParentResourceName()}/vehCruise`, { method:'POST' });
    if (btn.id === 'vehLimiter') fetch(`https://${GetParentResourceName()}/vehLimiter`, { method:'POST' });
    if (btn.id === 'vehDrift')   fetch(`https://${GetParentResourceName()}/vehDrift`, { method:'POST' });
  });
});

// Cercanos
function renderNearbyList(list){
  const box = document.getElementById('nearbyList');
  box.innerHTML = '';
  list.forEach(p => {
    const el = document.createElement('div');
    el.className = 'nearby-item';
    el.dataset.id = p.id;
    el.innerHTML = `<div>${p.name} <span style="opacity:.6">(${p.id})</span></div><div class="pill">~${p.dist}m</div>`;
    el.addEventListener('click', () => selectNearby(p, el));
    box.appendChild(el);
  });
}
function selectNearby(p, el){
  selectedNearby = p;
  document.querySelectorAll('.nearby-item').forEach(n => n.classList.remove('active'));
  el.classList.add('active');
  // Pedir inventario del otro jugador (cacheo/inspección)
  fetch(`https://${GetParentResourceName()}/requestNearbyInv`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ id: p.id })
  });
}

document.getElementById('giveItemBtn').addEventListener('click', () => {
  if (!selectedNearby || !selected.item || selected.owner !== 'player') return;
  const amount = prompt(`Cantidad a dar a ${selectedNearby.name}:`, '1'); if (!amount) return;
  fetch(`https://${GetParentResourceName()}/giveItem`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ target: selectedNearby.id, from: selected.slot, count: Number(amount) })
  });
});

document.getElementById('friskBtn').addEventListener('click', () => {
  if (!selectedNearby) return;
  fetch(`https://${GetParentResourceName()}/frisk`, {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ target: selectedNearby.id })
  });
});

// Hook para setear inventario del jugador cercano
window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'setNearbyInv') {
    const inv = Array.isArray(data.inv) ? data.inv : [];
    renderInventory('nearbyInventory', inv, 'nearby');
  }
});

// Utilidades
document.getElementById('openEditor').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/openEditor`, { method:'POST' });
});
document.querySelectorAll('.util-btn[data-util]').forEach(btn => {
  btn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/utilAction`, {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ action: btn.dataset.util })
    });
  });
});

// Ropa
document.querySelectorAll('.cloth-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/toggleCloth`, {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ part: btn.dataset.cloth })
    });
  });
});





