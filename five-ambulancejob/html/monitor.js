let visible=false;

window.addEventListener('message',(e)=>{
  const d=e.data||{};
  if(d.action==='showMonitor'){
    show(true);
    if(typeof d.patients==='number') document.getElementById('monPatients').textContent=d.patients;
  }else if(d.action==='hideMonitor'){
    show(false);
  }
});