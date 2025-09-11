let visible = false;

window.addEventListener('message', (e)=>{
  const d = e.data||{};
  if (d.action === 'showUI'){
    show(true);
    if (typeof d.nivel === 'number') document.getElementById('txNivel').textContent = d.nivel;
    setStage('waiting');
  }
  if (d.action === 'setStage'){
    if (typeof d.nivel === 'number') document.getElementById('txNivel').textContent = d.nivel;
    setStage(d.stage);
  }
  if (d.action === 'jobFinished'){
    toast(`Viaje terminado. Pago: $${d.pago} | XP total: ${d.xp}`);
    show(false);
  }
  if (d.action === 'jobFailed'){
    toast(`Trabajo fallido: ${d.reason||''}`);
    show(false);
  }
  if (d.action === 'damageBar'){
    document.getElementById('damageBar').classList.toggle('hidden', !d.show);
    if (typeof d.value === 'number') setDamage(d.value);
  }
  if (d.action === 'updateDamageBar'){
    setDamage(d.value||0);
  }
});

function show(s){ visible = !!s; document.getElementById('taxiUI').classList.toggle('hidden', !visible); }
function setStage(stage){
  document.getElementById('stageWaiting').classList.toggle('hidden', stage!=='waiting');
  document.getElementById('stagePickup').classList.toggle('hidden', stage!=='pickup');
  document.getElementById('stageDropoff').classList.toggle('hidden', stage!=='dropoff');
}
function setDamage(v){
  const pct = Math.max(0, Math.min(100, v));
  document.getElementById('damageFill').style.width = pct + '%';
}

function toast(msg){
  const t = document.getElementById('toast');
  t.textContent = msg; t.classList.remove('hidden');
  setTimeout(()=> t.classList.add('hidden'), 4000);
}

document.getElementById('closeBtn').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/closeUI`,{method:'POST'}));
document.getElementById('startJob').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/startJob`,{method:'POST'}));
document.getElementById('requestNPC').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/requestNPC`,{method:'POST'}));
document.getElementById('pickupDone').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/pickupDone`,{method:'POST'}));
document.getElementById('dropoffDone').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/dropoffDone`,{method:'POST'}));
document.getElementById('cancelJob').addEventListener('click', ()=> fetch(`https://${GetParentResourceName()}/cancelJob`,{method:'POST'}));
if (d.action === 'meter:show') document.getElementById('meter').classList.toggle('hidden', !d.show);
if (d.action === 'meter:update') {
  // d: { base, distCost, timeCost, km, min, tip, pen, total }
  document.getElementById('mBase').textContent  = `$${d.base|0}`;
  document.getElementById('mDist').textContent  = `$${d.distCost|0}`;
  document.getElementById('mKm').textContent    = `(${(d.km||0).toFixed(2)} km)`;
  document.getElementById('mTime').textContent  = `$${d.timeCost|0}`;
  document.getElementById('mMin').textContent   = `(${(d.min||0).toFixed(1)} min)`;
  document.getElementById('mTip').textContent   = `$${Math.max(0,d.tip|0)}`;
  document.getElementById('mPen').textContent   = `-$${Math.max(0,d.pen|0)}`;
  document.getElementById('mTotal').textContent = `$${Math.max(0,d.total|0)}`;
}
document.getElementById('addTip').addEventListener('click', ()=>{
  const tip = parseInt(prompt('Ingrese la propina que desea dar al cliente:', '0')||'0')||0;
  fetch(`https://${GetParentResourceName()}/addTip`, { method:'POST', body: JSON.stringify({ tip }) });
});