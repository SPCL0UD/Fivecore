let visible = false;

window.addEventListener('message', (e) => {
  const d = e.data || {};
  if (d.action === 'abrirTablet') {
    visible = true;
    document.getElementById('tabletUI').classList.remove('hidden');
  }
  if (d.action === 'mostrarResultados') {
    mostrarResultados(d.resultados || []);
  }
  if (d.action === 'tablet:mapUpdate') {
    actualizarMapa(d.patrullas || [], d.rastreados || [], d.bodycams || []);
  }
});

document.getElementById('closeBtn').addEventListener('click', () => {
  visible = false;
  document.getElementById('tabletUI').classList.add('hidden');
  fetch(`https://${GetParentResourceName()}/cerrarTablet`, { method: 'POST' });
});

document.getElementById('searchBtn').addEventListener('click', () => {
  const query = document.getElementById('searchInput').value;
  fetch(`https://${GetParentResourceName()}/buscarCiudadano`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query })
  });
});

document.getElementById('registerSuspect').addEventListener('click', () => {
  const name = document.getElementById('suspectName').value;
  const id = document.getElementById('suspectID').value;
  fetch(`https://${GetParentResourceName()}/registrarSospechoso`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, id })
  });
});

document.getElementById('capturePhoto').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/capturarFoto`, { method: 'POST' });
});

document.getElementById('issueFine').addEventListener('click', () => {
  const id = document.getElementById('fineTargetID').value;
  const tipo = document.getElementById('fineType').value;
  fetch(`https://${GetParentResourceName()}/emitirMulta`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id, tipo })
  });
});

document.getElementById('recruitBtn').addEventListener('click', () => {
  const name = document.getElementById('recruitName').value;
  const id = document.getElementById('recruitID').value;
  fetch(`https://${GetParentResourceName()}/contratarPolicia`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, id })
  });
});

document.getElementById('enterService').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/entrarServicio`, { method: 'POST' });
});

document.getElementById('exitService').addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/salirServicio`, { method: 'POST' });
});

function mostrarResultados(data) {
  const box = document.getElementById('resultsBox');
  box.innerHTML = '';
  if (data.length === 0) {
    box.innerHTML = '<p>No se encontraron resultados.</p>';
    return;
  }

  data.forEach((r) => {
    const div = document.createElement('div');
    div.className = 'result';
    div.innerHTML = `
      <b>${r.nombre}</b> · ID: ${r.id}<br>
      <small>Multas: $${r.multas} · Antecedentes: ${r.antecedentes} · Órdenes: ${r.ordenes}</small><br>
      <details>
        <summary>Ver detalles</summary>
        <div>
          <b>Delitos:</b><br>
          ${r.detalles.delitos.map(d => `• ${d.tipo} (${d.fecha})`).join('<br>')}
          <br><b>Órdenes:</b><br>
          ${r.detalles.ordenes.map(o => `• ${o.tipo} (${o.fecha})`).join('<br>')}
        </div>
      </details>
    `;
    box.appendChild(div);
  });
}

function actualizarMapa(patrullas, rastreados, bodycams) {
  const canvas = document.getElementById('mapCanvas');
  canvas.innerHTML = '';

  const scale = 0.2;
  const offsetX = 200;
  const offsetY = 200;

  function crearIcono(x, y, tipo, label) {
    const icon = document.createElement('div');
    icon.className = 'map-icon ' + tipo;
    icon.style.left = (x * scale + offsetX) + 'px';
    icon.style.top = (y * scale + offsetY) + 'px';
    icon.textContent = tipo === 'patrol' ? '🚓' : tipo === 'tracked' ? '🎯' : '📹';
    icon.title = label;
    canvas.appendChild(icon);
  }

  patrullas.forEach(p => crearIcono(p.coords.x, p.coords.y, 'patrol', p.nombre));
  rastreados.forEach(v => crearIcono(v.coords.x, v.coords.y, 'tracked', v.placa));
  bodycams.forEach(b => crearIcono(b.coords.x, b.coords.y, 'bodycam', b.nombre));
}
// Cerrar tablet con Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && visible) {
    visible = false;
    document.getElementById('tabletUI').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/cerrarTablet`, { method: 'POST' });
  }
});