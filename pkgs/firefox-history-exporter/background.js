
function exportHistory() {
  const now = new Date();
  const startTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0); // Beginning of today

  browser.history.search({
    text: '',
    startTime: startTime,
    endTime: now,
    maxResults: 10000
  }).then(historyItems => {
    const historyData = JSON.stringify(historyItems, null, 2);
    const blob = new Blob([historyData], {type: 'application/json'});
    const url = URL.createObjectURL(blob);
    const date = now.toISOString().slice(0, 10); // YYYY-MM-DD
    const filename = `firefox-history/history-${date}.json`;

    browser.downloads.download({
      url: url,
      filename: filename,
      conflictAction: 'overwrite',
      saveAs: false
    });
  });
}

browser.alarms.create('daily-export', {
  periodInMinutes: 60 // every 1 hour
});

browser.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === 'daily-export') {
    exportHistory();
  }
});

browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.command === "exportHistory") {
    exportHistory();
  }
});
