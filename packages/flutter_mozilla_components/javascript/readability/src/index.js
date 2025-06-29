/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import { Readability, isProbablyReaderable } from '@mozilla/readability';
import TurndownService from 'turndown';

const removeMarkdown = require('remove-markdown');

const turndownService = new TurndownService();

function sanitizeHtmlTags(node, unwantedSelectors) {
    unwantedSelectors.forEach(selector => {
        node.querySelectorAll(selector).forEach(el => el.remove());
    });

    return node;
}

function parseFullMarkdown(node) {
    const clonedDoc = node.cloneNode(true);

    sanitizeHtmlTags(clonedDoc, [
        /* Navigation and Header Elements */
        'nav',
        'footer',
        'header',
        'aside',
        'menu',
        'toolbar',

        /* Interactive Elements */
        'form',
        'button',
        '[role="button"]',
        '[type="button"]',
        'dialog',
        'modal',

        /* Hidden Elements */
        '[aria-hidden="true"]',
        '[hidden]',
        '[style*="display: none"]',
        '[style*="visibility: hidden"]',
        '.hidden',
        '.invisible',

        /* Advertising and Marketing */
        '.ad',
        '.advertisement',
        '.banner',
        '.sponsored',
        '.promotion',
        '.popup',
        '.newsletter',
        '.subscribe',

        /* Social Media */
        '.social-share',
        '.social-media',
        '.share-buttons',
        '.follow-us',
        '.likes',
        '.comments',

        /* Common UI Components */
        '.cookie-notice',
        '.cookie-banner',
        '.modal',
        '.overlay',
        '.tooltip',
        '.popup',
        '.sidebar',
        '.widget',

        /* Navigation Related */
        '.breadcrumb',
        '.pagination',
        '.menu',
        '.navbar',
        '.navigation',

        /* Related Content */
        '.related-posts',
        '.recommended',
        '.suggestions',
        '.read-more',

        /* Interactive Features */
        '.search',
        '.search-box',
        '.login',
        '.signup',
        '.register',

        /* Print-specific */
        '.print-only',
        '[media="print"]'
    ]);

    const fullMarkdown = turndownService.turndown(clonedDoc.body.innerHTML);

    let response = {
        fullContentMarkdown: fullMarkdown,
        fullContentPlain: removeMarkdown(fullMarkdown),
    };

    return response;
}

function parseReaderable(document, options) {
    const clonedDoc = document.cloneNode(true);
    sanitizeHtmlTags(clonedDoc, [
        /* Technical Elements */
        'script',
        'style',
        'noscript',
        'iframe',
        'svg',
        'img',
        'video',
        'audio',
        'canvas',
        'object',
        'embed',
    ]);

    let response = parseFullMarkdown(clonedDoc);

    const readable = isProbablyReaderable(clonedDoc);

    const reader = new Readability(clonedDoc, options);
    const article = reader.parse();

    if (article != null) {
        const extractedMarkdown = turndownService.turndown(article.content);

        response = {
            ...response,
            isProbablyReaderable: readable ? 1 : 0,
            extractedContentMarkdown: extractedMarkdown,
            extractedContentPlain: removeMarkdown(extractedMarkdown)
        };
    }

    return response;
}

window.parseReaderable = parseReaderable;
window.parseFullMarkdown = parseFullMarkdown;

export { parseReaderable, parseFullMarkdown };