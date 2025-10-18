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
    case "getPrefList":
      browser.experiments.prefmanager.getPrefList()
        .then(sendJsonResultForRequest(requestId))
        .catch(sendErrorForRequest(requestId))
  }
});
