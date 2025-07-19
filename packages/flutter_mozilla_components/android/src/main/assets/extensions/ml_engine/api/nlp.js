/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

const { KeywordExtractor } = ChromeUtils.importESModule(
    "chrome://global/content/ml/NLPUtils.sys.mjs"
);

this.nlp = class extends ExtensionAPI {
    getAPI(context) {
        return {
            experiments: {
                nlp: {
                    async extractKeywords(corpus, maxKeywords = 3) {
                        try {
                            const keywordExtractor = new KeywordExtractor();
                            const keywords = keywordExtractor.fitTransform(corpus, maxKeywords);
                            return keywords;
                        } catch (error) {
                            throw new ExtensionError(`Keyword extraction failed: ${error.message}`);
                        }
                    },
                }
            }
        };
    }
};