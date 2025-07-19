/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

const { createEngine } = ChromeUtils.importESModule("chrome://global/content/ml/EngineProcess.sys.mjs");

const ML_TASK_FEATURE_EXTRACTION = "feature-extraction";
const ML_TASK_TEXT2TEXT = "text2text-generation";

const SMART_TAB_GROUPING_CONFIG = {
    embedding: {
        dtype: "q8",
        timeoutMS: 2 * 60 * 1000, // 2 minutes
        taskName: ML_TASK_FEATURE_EXTRACTION,
        featureId: "smart-tab-embedding",
        backend: "onnx",
    },
    topicGeneration: {
        dtype: "q8",
        timeoutMS: 2 * 60 * 1000, // 2 minutes
        taskName: ML_TASK_TEXT2TEXT,
        featureId: "smart-tab-topic",
        backend: "onnx",
    },
    // dataConfig: {
    //     titleKey: "label",
    //     descriptionKey: "description",
    // },
    // clustering: {
    //     dimReductionMethod: null, // Not completed.
    //     clusterImplementation: CLUSTER_METHODS.KMEANS,
    //     clusteringTriesPerK: 3,
    //     anchorMethod: ANCHOR_METHODS.FIXED,
    //     pregroupedHandlingMethod: PREGROUPED_HANDLING_METHODS.EXCLUDE,
    //     pregroupedSilhouetteBoost: 2, // Relative weight of the cluster's score and all other cluster's combined
    //     suggestOtherTabsMethod: SUGGEST_OTHER_TABS_METHODS.NEAREST_NEIGHBOR,
    // },
};

/**
 * Generate model input from keywords and documents
 * @param {string []} keywords
 * @param {string []} documents
 */
function createModelInput(keywords, documents) {
    if (!keywords || keywords.length === 0) {
        return `Topic from keywords: titles: \n${documents.join(" \n")}`;
    }
    return `Topic from keywords: ${keywords.join(", ")}. titles: \n${documents.join(" \n")}`;
}

/**
 * One artifact of the LLM output is that sometimes words are duplicated
 * This function cuts the phrase when it sees the first duplicate word.
 * Handles simple singluar / plural duplicates (-s only).
 * @param {string} phrase Input phrase
 * @returns {string} phrase cut before any duplicate word
 */
function cutAtDuplicateWords(phrase) {
    if (!phrase.length) {
        return phrase;
    }
    const wordsSet = new Set();
    const wordList = phrase.split(" ");
    for (let i = 0; i < wordList.length; i++) {
        let baseWord = wordList[i].toLowerCase();
        if (baseWord.length > 3) {
            if (baseWord.slice(-1) === "s") {
                baseWord = baseWord.slice(0, -1);
            }
        }
        if (wordsSet.has(baseWord)) {
            // We are seeing a baseWord word. Exit with just the words so far and don't
            // add any new words
            return wordList.slice(0, i).join(" ");
        }
        wordsSet.add(baseWord);
    }
    return phrase; // return original phrase
}


/**
   *
   * @param {MLEngine} engine the engine to check
   * @return {boolean} true if the engine has not been initialized or closed
   */
function isEngineClosed(engine) {
    return !engine || engine?.engineStatus === "closed";
}

this.ml = class extends ExtensionAPI {
    getAPI(context) {
        return {
            experiments: {
                ml: {
                    async containerTopic(keywords, documents) {
                        if (isEngineClosed(this.topicEngine)) {
                            const {
                                featureId,
                                engineId,
                                dtype,
                                taskName,
                                timeoutMS,
                                modelId,
                                modelRevision,
                                backend,
                            } = SMART_TAB_GROUPING_CONFIG.topicGeneration;

                            let initData = {
                                featureId,
                                engineId,
                                dtype,
                                taskName,
                                timeoutMS,
                                modelId,
                                modelRevision,
                                backend,
                            };

                            this.topicEngine = await createEngine(initData);
                        }

                        const inputArgs = createModelInput(
                            keywords,
                            documents
                        );
                        const requestInfo = {
                            inputArgs,
                            runOptions: {
                                max_length: 6,
                            },
                        };
                        const request = {
                            args: [requestInfo.inputArgs],
                            options: requestInfo.runOptions,
                        };

                        const res = await this.topicEngine.run(request);

                        const generated = cutAtDuplicateWords((res[0]["generated_text"] || "").trim());

                        return generated;
                    }
                }
            }
        };
    }
};