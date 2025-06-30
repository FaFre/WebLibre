'use strict';

const encoder = new TextEncoder();

const port = browser.runtime.connectNative("prefManager");

function sendJsonResultForRequest(id) {
  return function (result) {
    port.postMessage({
      "id": id,
      "status": "success",
      "result": result
    })
  }
}

function sendErrorForRequest(id) {
  return function (error) {
    console.error(error);
    port.postMessage({
      "id": id,
      "status": "error",
      "error": error
    });
  }
}

port.onMessage.addListener(message => {
  let requestId = message["id"]
  switch (message["action"]) {
    case "parsePrefsAndApply":
      browser.experiments.prefmanager.parsePrefsAndApply(encoder.encode(message["args"]), null)
        .then(sendJsonResultForRequest(requestId))
        .catch(sendErrorForRequest(requestId))
      break
    case "getPrefs":
      browser.experiments.prefmanager.getPrefs(message["args"])
        .then(sendJsonResultForRequest(requestId))
        .catch(sendErrorForRequest(requestId))
      break
    case "resetPrefs":
      browser.experiments.prefmanager.resetPrefs(message["args"])
        .then(sendJsonResultForRequest(requestId))
        .catch(sendErrorForRequest(requestId))
      break
  }
});
