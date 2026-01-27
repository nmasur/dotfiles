document.getElementById('export-button').addEventListener('click', () => {
  browser.runtime.sendMessage({command: "exportHistory"});
  
  const statusElement = document.getElementById('status');
  statusElement.textContent = 'Exporting...';
  setTimeout(() => {
    statusElement.textContent = 'Export complete!';
  }, 2000);
});
