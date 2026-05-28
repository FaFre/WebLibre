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
        const message = error?.message || String(error);
        port.postMessage({
            "id": id,
            "status": "error",
            "error": message,
            "errorName": error?.name,
            "errorStack": error?.stack,
            "errorString": String(error)
        });
    }
}

browser.experiments.ml.onProgress.addListener((progressData) => {
    port.postMessage({
        type: "mlProgress",
        progress: progressData
    });
});

port.onMessage.addListener(async (message) => {
    const requestId = message["id"];

    try {
        switch (message["action"]) {
            case "predictDocumentTopic": {
                const documents = message["args"];
                const keywords = (documents.length > 1)
                    ? await browser.experiments.nlp.extractKeywords([documents.slice(0, 3).join(" ")])
                    : [[]];
                const result = await browser.experiments.ml.predictTopic(keywords[0], documents);

                sendJsonResultForRequest(requestId)(result);
                break;
            }
            case "generateDocumentEmbeddings": {
                const documents = message["args"];
                const result = await browser.experiments.ml.generateEmbeddings(documents);

                sendJsonResultForRequest(requestId)(result);
                break;
            }
            default:
                throw new Error(`Unsupported ML action: ${message["action"]}`);
        }
    } catch (error) {
        sendErrorForRequest(requestId)(error);
    }
});
