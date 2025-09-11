window.addEventListener('message', function (event) {
  const data = event.data;
  if (data.action === "open") {
    document.getElementById("jobList").innerHTML = "";
    data.jobs.forEach(job => {
      const div = document.createElement("div");
      div.className = "jobItem";
      div.innerHTML = `<span>${job.icon} ${job.label}</span><small>${job.description}</small>`;
      div.onclick = () => {
        fetch(`https://${GetParentResourceName()}/selectJob`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ id: job.id })
        });
      };
      document.getElementById("jobList").appendChild(div);
    });
    document.getElementById("jobPanel").style.display = "block";
  }
});

function closePanel() {
  document.getElementById("jobPanel").style.display = "none";
  fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}
document.getElementById("closeBtn").onclick = closePanel;
document.getElementById("jobPanel").onclick = function (e) {
  if (e.target.id === "jobPanel") closePanel();
};