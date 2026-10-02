const parser = new DOMParser();

port.onMessage.addListener(message => {
  let requestId = message["id"];

  switch (message["action"]) {
    case "turndown":
      // Handle array of HTML strings
      if (Array.isArray(message.args)) {
        const results = message.args.map(htmlString => {
          // Caught per document: an exception escaping this listener sends no
          // reply at all, and the whole batch would time out over one entry.
          // Reported as an error, not as empty text, which would read as a
          // document that converted to nothing.
          try {
            const document = parser.parseFromString(htmlString, 'text/html');
            return parseFullMarkdown(document);
          } catch (error) {
            console.error("Failed to convert a document to markdown", error);
            return { "error": String(error) };
          }
        });

        port.postMessage({
          "type": "turndown",
          "id": requestId,
          "status": "success",
          "result": results
        });
      } else {
        // Handle error case for invalid input
        port.postMessage({
          "type": "turndown",
          "id": requestId,
          "status": "error",
          "error": "Expected args to be an array of HTML strings"
        });
      }
      break;
  }
});
