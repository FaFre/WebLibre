import BackgroundMain from '../../src/background/BackgroundMain'
import { Store } from '../../src/store/Store'

import { expect } from 'chai'

/* eslint-disable @typescript-eslint/no-unused-expressions */

const chrome = require('sinon-chrome/extensions')

/**
 * What `onBeforeRequest` tells the app. A cancelled navigation is reported
 * for every tab, so a background tab it refuses is reopened in its assigned
 * container (or the strict block is shown) instead of staying blank; an
 * allowed one only for the highlighted tab.
 */
describe('reporting of navigations to the app', function () {
  let backgroundMain: BackgroundMain
  let messages: any[]
  let port: browser.runtime.Port

  beforeEach(() => {
    global.browser = chrome
    const store = new Store()
    store.applySnapshot({
      generation: 1,
      proxies: [],
      // Two containers that route apart, so an assignment to one cancels the
      // navigation in the other.
      relations: { work: ['proxy-a'], shop: ['proxy-b'] },
      directScopes: {},
      siteAssignments: { 'https://work.example': 'work' },
      strictContexts: { strict: ['strict'] }
    })
    backgroundMain = new BackgroundMain({ store })
    messages = []
    port = { postMessage: (message: any) => messages.push(message) } as unknown as browser.runtime.Port
  })

  afterEach(() => {
    chrome.flush()
    // @ts-expect-error
    delete global.browser
  })

  async function navigate (options: { context: string, highlighted: boolean, url: string }): Promise<browser.webRequest.BlockingResponse> {
    chrome.tabs.get.withArgs(7).resolves({
      id: 7,
      highlighted: options.highlighted,
      url: 'https://opener.example/',
      cookieStoreId: `firefox-container-${options.context}`
    })
    return await backgroundMain.onBeforeRequest({
      tabId: 7,
      frameId: 0,
      url: options.url,
      requestId: 'r1'
    } as any, port)
  }

  it('reports a site assigned elsewhere for a background tab', async () => {
    const response = await navigate({ context: 'shop', highlighted: false, url: 'https://work.example/page' })

    expect(response.cancel).to.be.true
    expect(messages).to.have.length(1)
    expect(messages[0].result).to.include({
      url: 'https://work.example/page',
      // The page the tab is still on, by which native finds it.
      tabUrl: 'https://opener.example/',
      highlighted: false,
      blocked: true,
      strict: false
    })
  })

  it('reports where a redirected request started', async () => {
    // A fresh background tab opens on an unassigned page, which redirects
    // (same request id) to a site assigned elsewhere.
    const first = await navigate({ context: 'shop', highlighted: false, url: 'https://start.example/' })
    expect(first.cancel).to.be.undefined
    expect(messages).to.be.empty

    const hop = await navigate({ context: 'shop', highlighted: false, url: 'https://work.example/' })
    expect(hop.cancel).to.be.true
    expect(messages).to.have.length(1)
    expect(messages[0].result).to.include({
      url: 'https://work.example/',
      startUrl: 'https://start.example/',
      blocked: true
    })
  })

  it('reports a strict block for a background tab', async () => {
    const response = await navigate({ context: 'strict', highlighted: false, url: 'https://elsewhere.example/' })

    expect(response.cancel).to.be.true
    expect(messages).to.have.length(1)
    expect(messages[0].result).to.include({ highlighted: false, blocked: true, strict: true })
  })

  it('reports a cancelled navigation of the highlighted tab as highlighted', async () => {
    await navigate({ context: 'shop', highlighted: true, url: 'https://work.example/' })

    expect(messages).to.have.length(1)
    expect(messages[0].result).to.include({ highlighted: true, blocked: true })
  })

  it('reports an allowed navigation for the highlighted tab only', async () => {
    const background = await navigate({ context: 'work', highlighted: false, url: 'https://work.example/' })
    expect(background.cancel).to.be.undefined
    expect(messages).to.be.empty

    const highlighted = await navigate({ context: 'work', highlighted: true, url: 'https://work.example/' })
    expect(highlighted.cancel).to.be.undefined
    expect(messages).to.have.length(1)
    expect(messages[0].result).to.include({ highlighted: true, blocked: false })
  })
})
