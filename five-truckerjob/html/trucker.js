let uiVisible = false;
let hubs = [];
let playerXP = 0;
let selectedHub = null;
let currentJob = null;
let groupMembers = [];

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'showHubs') {
    uiShow(true);
    hubs = data.hubs || [];
    playerXP = Number(data.xp || 0);
    renderHeaderXP(playerXP);
    renderHubs(hubs);
    switchTab('tab-hubs');
  }
  if (data.action === 'showTruckerUI') {
    uiShow(true);
    // data.cargo, data.jobType
    currentJob = { cargo: data.cargo, type: data.jobType, load: 0, deliver: 0 };
    renderActive(currentJob);
    switchTab('tab-active');
  }
  if (data.action === 'updateXP') {
    playerXP = Number(data.xp || 0);
    renderHeaderXP(playerXP);
  }
  if (data.action === 'updateGroup') {
    groupMembers = data.members || [];
    renderGroup(groupMembers);
  }
  if (data.action === 'updateActive') {
    // server puede empujar progreso de carga/entrega
    if (!currentJob) currentJob = {};
    currentJob.load = data.load ?? currentJob.load ?? 0;
    currentJob.deliver = data.deliver ?? currentJob.deliver ?? 0;
    renderActive(currentJob);
  }
});

function uiShow(show){
  uiVisible = !!show;
  document.getElementById('truckerUI').classList.toggle('hidden', !uiVisible);
}

function switchTab(id){
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
  document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));
  document.querySelector(`.tab-btn[data-tab="${id}"]`)?.classList.add('active');
  document.getElementById(id)?.classList.add('active');
}

// Header XP
function renderHeaderXP(xp){
  const levelInfo = computeLevel(xp);
  document.getElementById('tkLevel').textContent = levelInfo.level;
  document.getElementById('tkXP').textContent = levelInfo.currXP;
  document.getElementById('tkNextXP').textContent = levelInfo.nextXP;
  document.getElementById('tkXPFill').style.width = `${levelInfo.pct}%`;
}

function computeLevel(xp){
  // Niveles genéricos: 0,100,300,600,1000...
  const thresholds = [0,100,300,600,1000,1500,2100];
  let level = 1, nextXP = thresholds[1] || 100, currBase = 0;
  for (let i=0;i<thresholds.length;i++){
    if (xp >= thresholds[i]) { level = i+1; currBase = thresholds[i]; nextXP = thresholds[i+1] || thresholds[i]+500; }
  }
  const currXP = xp - currBase;
  const span = nextXP - currBase;
  const pct = span > 0 ? Math.min(100, Math.round((currXP/span)*100)) : 0;
  return { level, currXP, nextXP, pct };
}

// Render Hubs
function renderHubs(list){
  const box = document.getElementById('tkHubsList');
  box.innerHTML = '';
  list.forEach(h => {
    const el = document.createElement('div');
    el.className = 'hub-card';
    el.innerHTML = `
      <div class="title">${h.name}</div>
      <div class="meta">
        <span class="pill">${h.type === 'ilegal' ? 'Ilegal' : 'Legal'}</span>
        <span class="pill">(${Math.round(h.coords.x)}, ${Math.round(h.coords.y)})</span>
      </div>
    `;
    el.addEventListener('click', () => selectHub(h));
    box.appendChild(el);
  });
}

function selectHub(h){
  selectedHub = h;
  document.getElementById('tkHubTitle').textContent = h.name;
  document.getElementById('tkHubType').textContent = h.type === 'ilegal' ? 'Ilegal' : 'Legal';
  document.getElementById('tkHubCoords').textContent = `X:${Math.round(h.coords.x)} Y:${Math.round(h.coords.y)}`;
  renderLevels(h.levels, playerXP);
  renderCargoForHub(h, playerXP);
}

function renderLevels(levels, xp){
  const row = document.getElementById('tkLevelsRow');
  row.innerHTML = '';
  const entries = Object.entries(levels).sort((a,b)=>Number(a[0])-Number(b[0]));
  entries.forEach(([lvl, data])=>{
    const locked = xp < (data.xp||0);
    const div = document.createElement('div');
    div.className = `level-chip ${locked?'locked':''}`;
    div.textContent = `Nivel ${lvl} · XP ${data.xp}`;
    row.appendChild(div);
  });
}

function renderCargoForHub(h, xp){
  const list = document.getElementById('tkCargoList');
  list.innerHTML = '';
  const entries = Object.entries(h.levels).sort((a,b)=>Number(a[0])-Number(b[0]));
  let allowedCargos = [];
  entries.forEach(([lvl, data])=>{
    if (xp >= (data.xp||0)) allowedCargos = allowedCargos.concat(data.cargos||[]);
  });

  // map cargoId -> cargo def
  const cargoDefs = (h.type === 'ilegal') ? (window.CFG_ILEGAL || {}) : (window.CFG_LEGAL || {});
  allowedCargos.forEach(cid=>{
    const c = cargoDefs[cid];
    if (!c) return;
    const card = document.createElement('div');
    card.className = 'cargo-card';
    card.innerHTML = `
      <div class="cargo-row"><div><b>${c.label}</b></div><div>$${c.pay}</div></div>
      <div class="cargo-row"><div>Alquiler</div><div>$${c.rent}</div></div>
      <div class="cargo-row"><div>XP</div><div>${c.xp}</div></div>
      <div class="cargo-row"><div>Carga</div><div>${c.loadTime}s</div></div>
      <div class="actions">
        <button class="btn" data-cid="${cid}">Iniciar solo</button>
        <button class="btn ghost" data-cid="${cid}" data-mode="group">Iniciar en grupo</button>
      </div>
    `;
    card.querySelectorAll('button').forEach(btn=>{
      btn.addEventListener('click', ()=>{
        const mode = btn.dataset.mode || 'solo';
        fetch(`https://${GetParentResourceName()}/selectHubCargo`,{
          method:'POST',headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ hubIndex: h.index, cargoId: cid, mode })
        });
      });
    });
    list.appendChild(card);
  });
}

/* Trabajo activo */
function renderActive(job){
  document.getElementById('tkActiveCargo').textContent = job?.cargo?.label || 'Sin trabajo activo';
  document.getElementById('tkActiveType').textContent  = (job?.type==='ilegal'?'Ilegal':'Legal') || '—';
  document.getElementById('tkActivePay').textContent   = `Pago: $${job?.cargo?.pay||0}`;
  document.getElementById('tkActiveRent').textContent  = `Alquiler: $${job?.cargo?.rent||0}`;
  document.getElementById('tkLoadFill').style.width    = `${job?.load||0}%`;
  document.getElementById('tkDeliverFill').style.width = `${job?.deliver||0}%`;
  document.getElementById('tkFinishJob').disabled = !job || (job.deliver||0) < 100;
}

/* Grupo */
function renderGroup(members){
  const box = document.getElementById('tkGroupList');
  box.innerHTML = '';
  if (!members.length){
    box.innerHTML = '<div class="hint">No hay miembros en el grupo.</div>';
    return;
  }
  members.forEach(m=>{
    const el = document.createElement('div');
    el.className = 'group-item';
    el.innerHTML = `<div>${m.name} <span style="opacity:.6">(${m.id})</span></div><div class="pill">${m.role||'Miembro'}</div>`;
    box.appendChild(el);
  });
}

/* Exponer config (el server puede preinyectar estos objetos si querés) */
window.CFG_LEGAL = {};   // opcional: el server puede llenar via message
window.CFG_ILEGAL = {};

document.getElementById('tkClose').addEventListener('click',()=>{
  uiShow(false);
  fetch(`https://${GetParentResourceName()}/closeUI`,{method:'POST'});
});

/* Tabs */
document.querySelectorAll('.tab-btn').forEach(btn=>{
  btn.addEventListener('click',()=> switchTab(btn.dataset.tab));
});

/* Trabajo activo: acciones */
document.getElementById('tkStartLoad').addEventListener('click',()=>{
  fetch(`https://${GetParentResourceName()}/startLoading`,{method:'POST'});
});
document.getElementById('tkLoadTick').addEventListener('click',()=>{
  // cada tick indica que el jugador cargó una pieza (cliente hará la animación)
  fetch(`https://${GetParentResourceName()}/loadTick`,{method:'POST'});
});
document.getElementById('tkFinishJob').addEventListener('click',()=>{
  fetch(`https://${GetParentResourceName()}/finishJob`,{method:'POST'});
});
document.getElementById('tkCancelJob').addEventListener('click',()=>{
  fetch(`https://${GetParentResourceName()}/cancelJob`,{method:'POST'});
});

/* Grupo: acciones */
document.getElementById('tkCreateGroup').addEventListener('click',()=>{
  fetch(`https://${GetParentResourceName()}/groupCreate`,{method:'POST'});
});
document.getElementById('tkLeaveGroup').addEventListener('click',()=>{
  fetch(`https://${GetParentResourceName()}/groupLeave`,{method:'POST'});
});
document.getElementById('tkInviteBtn').addEventListener('click',()=>{
  const id = Number(document.getElementById('tkInviteId').value||0);
  if (id>0){
    fetch(`https://${GetParentResourceName()}/groupInvite`,{
      method:'POST',headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ id })
    });
  }
});

/* NUI helpers para cliente:
  - showHubs { hubs, xp }
  - showTruckerUI { cargo, jobType }
  - updateXP { xp }
  - updateGroup { members }
  - updateActive { load, deliver }
*/
