'use strict';

const port = browser.runtime.connectNative("mlEngine");

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

port.onMessage.addListener(async (message) => {
    let requestId = message["id"]
    switch (message["action"]) {
        case "getContainerTopic":
            const documents = message["args"];
            const keywords = await browser.experiments.nlp.extractKeywords([documents.slice(0, 3).join(" ")]);

            browser.experiments.ml.containerTopic(keywords[0], documents)
                .then(sendJsonResultForRequest(requestId))
                .catch(sendErrorForRequest(requestId))
            break
    }
});
