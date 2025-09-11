let uiVisible = false;
let deposits = [];
let levels = {};
let playerXP = 0;
let selectedDepositIndex = null;

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'showDeposits') {
    uiShow(true);
    deposits = data.deposits || [];
    levels = data.levels || {};
    playerXP = Number(data.xp || 0);
    renderHeaderXP(playerXP);
    renderDeposits(deposits);
    switchTab('tab-deposits');
  }
  if (data.action === 'showGarbageUI') {
    uiShow(true);
    renderActiveHeader(data.route || {});
    switchTab('tab-active');
  }
  if (data.action === 'updateProgress') {
    if (typeof data.pointsPct === 'number') {
      setProgress('gbPointsFill', data.pointsPct);
      if (data.pointsPct >= 100) {
        setProgress('gbDumpFill', 100);
        document.getElementById('gbFinishJob').disabled = false;
      }
    }
  }
  if (data.action === 'jobFinished') {
    alert(`Trabajo completado. Pago: $${data.pago}\nXP total: ${data.xp}`);
    uiShow(false);
  }
  if (data.action === 'jobCanceled') {
    alert('Trabajo cancelado.');
    uiShow(false);
  }
  if (data.action === 'jobFailed') {
    alert('Trabajo fallido: ' + (data.reason || ''));
    uiShow(false);
  }
});

function uiShow(show){
  uiVisible = !!show;
  document.getElementById('garbageUI').classList.toggle('hidden', !uiVisible);
}

function switchTab(id){
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
  document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));
  document.querySelector(`.tab-btn[data-tab="${id}"]`)?.classList.add('active');
  document.getElementById(id)?.classList.add('active');
}

function renderHeaderXP(xp){
  const info = computeLevel(xp);
  document.getElementById('gbLevel').textContent = info.level;
  document.getElementById('gbXP').textContent = info.currXP;
  document.getElementById('gbNextXP').textContent = info.nextXP;
  document.getElementById('gbXPFill').style.width = `${info.pct}%`;
}

function computeLevel(xp){
  const thresholds = [0,100,300,600,1000,1500,2100];
  let level = 1, nextXP = thresholds[1] || 100, currBase = 0;
  for (let i=0;i<thresholds.length;i++){
    if (xp >= thresholds[i]) { level = i+1; currBase = thresholds[i]; nextXP = thresholds[i+1] || thresholds[i] + 500; }
  }
  const currXP = xp - currBase;
  const span = nextXP - currBase;
  const pct = span > 0 ? Math.min(100, Math.round((currXP/span)*100)) : 0;
  return { level, currXP, nextXP, pct };
}

function renderDeposits(list){
  const box = document.getElementById('gbDepositsList');
  box.innerHTML = '';
  list.forEach((d, idx) => {
    const el = document.createElement('div');
    el.className = 'dep-card';
    el.innerHTML = `
      <div class="title">${d.name}</div>
      <div class="pill">X:${Math.round(d.coords.x)} Y:${Math.round(d.coords.y)}</div>
    `;
    el.addEventListener('click', () => selectDeposit(idx));
    box.appendChild(el);
  });
}

function selectDeposit(index){
  selectedDepositIndex = index;
  const dep = deposits[index];
  document.getElementById('gbDepositTitle').textContent = dep.name;
  renderLevels(levels, playerXP);
  renderRoutesForDeposit(index, playerXP);
}

function renderLevels(levelsMap, xp){
  const row = document.getElementById('gbLevelsRow');
  row.innerHTML = '';
  const entries = Object.entries(levelsMap).sort((a,b)=> Number(a[0])-Number(b[0]));
  entries.forEach(([lvl, data]) => {
    const locked = xp < (data.xp || 0);
    const div = document.createElement('div');
    div.className = `level-chip ${locked?'locked':''}`;
    div.textContent = `Nivel ${lvl} · XP ${data.xp}`;
    row.appendChild(div);
  });
}

function renderRoutesForDeposit(index, xp){
  const list = document.getElementById('gbRouteList');
  list.innerHTML = '';
  const allowed = [];
  Object.entries(levels).forEach(([lvl, data])=>{
    if (xp >= (data.xp||0)){
      (data.rutas||[]).forEach(r=> allowed.push(r));
    }
  });

  allowed.forEach(rid=>{
    const r = window.GB_CFG_ROUTES?.[rid];
    if (!r) return;
    const card = document.createElement('div');
    card.className = 'route-card';
    card.innerHTML = `
      <div class="route-row"><div><b>${r.label}</b></div><div>$${r.pago}</div></div>
      <div class="route-row"><div>Bolsas</div><div>${r.bolsas}</div></div>
      <div class="route-row"><div>Puntos</div><div>${(r.puntos||[]).length}</div></div>
      <div class="route-row"><div>XP</div><div>${r.xp}</div></div>
      <div class="actions">
        <button class="btn" data-rid="${rid}">Iniciar</button>
      </div>
    `;
    card.querySelector('button').addEventListener('click', ()=>{
      fetch(`https://${GetParentResourceName()}/startGarbageJob`, {
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ depositoIndex: index+1, rutaId: rid })
      });
    });
    list.appendChild(card);
  });
}

function renderActiveHeader(route){
  document.getElementById('gbActiveRoute').textContent = route.label || 'Ruta';
  document.getElementById('gbActivePay').textContent  = `Pago: $${route.pago||0}`;
  document.getElementById('gbActiveXP').textContent   = `XP: ${route.xp||0}`;
  setProgress('gbPointsFill', 0);
  setProgress('gbDumpFill', 0);
  document.getElementById('gbFinishJob').disabled = true;
}

function setProgress(id, pct){
  const el = document.getElementById(id);
  if (el) el.style.width = `${Math.max(0, Math.min(100, pct))}%`;
}

/* Botones */
document.getElementById('gbClose').addEventListener('click', ()=>{
  fetch(`https://${GetParentResourceName()}/gbClose`, { method:'POST' });
});

/* Activo */
document.getElementById('gbNextPoint').addEventListener('click', ()=>{
  fetch(`https://${GetParentResourceName()}/goNextPoint`, { method:'POST' });
});
document.getElementById('gbFinishJob').addEventListener('click', ()=>{
  fetch(`https://${GetParentResourceName()}/finishJob`, { method:'POST' });
});
document.getElementById('gbCancelJob').addEventListener('click', ()=>{
  fetch(`https://${GetParentResourceName()}/cancelJob`, { method:'POST' });
});

/* Atajo: cargar bolsa con E mientras la UI está abierta (opcional) */
document.addEventListener('keydown', (e)=>{
  if (!uiVisible) return;
  if (e.key.toLowerCase() === 'e') {
    fetch(`https://${GetParentResourceName()}/bagLoaded`, { method:'POST' });
  }
});

/* Exponer rutas para que la UI pueda leer el detalle sin pedirlo al server (opcional) */
window.GB_CFG_ROUTES = {}; // si querés, el cliente puede setear esto desde Lua con SendNUIMessage
document.getElementById('gbLoadBag').addEventListener('click', ()=>{
  fetch(`https://${GetParentResourceName()}/bagLoaded`, { method:'POST' });
});
