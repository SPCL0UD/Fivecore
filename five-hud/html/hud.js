window.addEventListener('message', function(event) {
  if (event.data.action === 'updateHUD') {
    document.getElementById('cash').textContent = event.data.cash;
    document.getElementById('bank').textContent = event.data.bank;
    document.getElementById('crypto').textContent = event.data.crypto;
    document.getElementById('jobName').textContent = event.data.jobLabel || 'Sin trabajo';
    document.getElementById('jobGrade').textContent = event.data.jobGradeLabel ? `- ${event.data.jobGradeLabel}` : '';
  }
  if (event.data.action === 'toggleHUD') {
    const hud = document.getElementById('hud');
    hud.style.opacity = hud.style.opacity === '0' ? '1' : '0';
    hud.style.transition = 'opacity 0.3s ease';
  }
});

