const port = browser.runtime.connectNative("mozacTurndownHtml");
const parser = new DOMParser();

port.onMessage.addListener(message => {
  let requestId = message["id"];

  switch (message["action"]) {
    case "turndown":
      console.log(message.args)
      // Handle array of HTML strings
      if (Array.isArray(message.args)) {
        const results = message.args.map(htmlString => {
          const document = parser.parseFromString(htmlString, 'text/html');
          return parseFullMarkdown(document);
        });

        port.postMessage({
          "id": requestId,
          "status": "success",
          "result": results
        });
      } else {
        // Handle error case for invalid input
        port.postMessage({
          "id": requestId,
          "status": "error",
          "error": "Expected args to be an array of HTML strings"
        });
      }
      break;
  }
});
