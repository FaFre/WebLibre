const port = browser.runtime.connectNative("mozacReaderExtract");

let domChanged = false;
let lastContent = '';

function parseContent() {
  const article = window.parseReaderable(document);

  if (article && lastContent !== article.textContent) {
      port.postMessage(article);

      lastContent = article.textContent;
  }

  domChanged = false;
}

port.onMessage.addListener((message) => {
  if (message.action === "parseContent") {
    if (domChanged) {
      parseContent();
    }
  }
});

const observer = new MutationObserver(() => {
  domChanged = true;
});

const observerConfig = {
  childList: true,
  subtree: true,
  characterData: true,
  attributes: false
};

// Wait for page to be fully loaded
if (document.readyState === 'complete') {
  parseContent();
  observer.observe(document.body, observerConfig);
} else {
  window.addEventListener('load', parseContent);
}

window.addEventListener('unload', () => {
  observer.disconnect();
});
