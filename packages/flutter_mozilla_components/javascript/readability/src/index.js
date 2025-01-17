import { Readability, isProbablyReaderable } from '@mozilla/readability';
import TurndownService from 'turndown';

const removeMarkdown = require('remove-markdown');

const turndownService = new TurndownService();

function parseReaderable(document, options) {
  const clonedDoc = document.cloneNode(true);
  const readable = isProbablyReaderable(clonedDoc);

  const fullMarkdown = turndownService.turndown(clonedDoc.body.innerHTML);

  let response = {
    fullContentMarkdown: fullMarkdown,
    fullContentPlain: removeMarkdown(fullMarkdown),
  }

  const reader = new Readability(clonedDoc, options);
  const article = reader.parse();

  if(article != null) {
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
export { parseReaderable };