const PageObject = require('./page-objects/PageObject.js')
const OptionsPageObject = require('./page-objects/OptionsPageObject.js')

const path = require('path')
const assert = require('chai')
const expect = assert.expect

const webExtensionsGeckoDriver = require('webextensions-geckodriver')
const { webdriver, firefox } = webExtensionsGeckoDriver
const { until, By } = webdriver

const manifestPath = path.resolve(path.join(__dirname, '../../dist/manifest.json'))

describe('Container Proxy extension', function () {
  let geckodriver
  this.timeout(30000)

  before(async () => {
    const fxOptions = new firefox.Options()
    if (process.env.HEADLESS) {
      fxOptions.headless()
        .windowSize({ height: 1080, width: 1920 })
    }

    const webExtension = await webExtensionsGeckoDriver(manifestPath, { fxOptions })
    geckodriver = webExtension.geckodriver
  })

  it('should add a proxy', async () => {
    const helper = new Helper(geckodriver)

    const options = await helper.openOptionsPage()

    let proxyList = await options.openProxyList()

    const proxyForm = await proxyList.openAddProxyForm()

    await proxyForm.selectProtocol('socks')
    await proxyForm.typeInServer('localhost')
    await proxyForm.typeInPort(1080)
    await proxyForm.typeInUsername('user')
    await proxyForm.typeInPassword('password')

    await proxyForm.testSettings()

    proxyList = await proxyForm.saveSettings()

    const proxyLabel = 'socks://localhost:1080'
    await geckodriver.wait(async () => {
      const row = await geckodriver.wait(until.elementLocated(
        By.css('.proxy-list-item:first-of-type')
      ), 2000)

      const label = row.findElement(By.css('.proxy-name'))

      const text = await label.getText()
      return text === proxyLabel
    }, 1000, 'Should show proxy in the list')

    const assign = await options.openAssignProxy()
    const defaultContainerSelect = await assign.defaultContainerSelect()
    await defaultContainerSelect.selectByLabel(proxyLabel)
  })

  it.skip('should contain IP address text', async () => {
    await geckodriver.setContext(firefox.Context.CONTENT)
    await geckodriver.get('https://api.duckduckgo.com/?q=ip&no_html=1&format=json&t=firefox-container-proxy-extension')
    const text = await geckodriver.getPageSource()

    expect(text).to.include('Your IP address is')
  })

  it('should successfully use SOCKS5 proxy for default container', async () => {
    const helper = new Helper(geckodriver)

    const optionsPage = await helper.openOptionsPage()
    const proxyList = await optionsPage.openProxyList()
    const addProxyForm = await proxyList.openAddProxyForm()
    const title = 'Valid SOCKS5 proxy'
    await addProxyForm.addProxy({
      title: title,
      type: 'socks',
      server: 'localhost',
      port: 1080,
      username: 'user',
      password: 'password'
    })
    // TODO: Check if username and password are actually verified by "dante"

    const assignProxy = await optionsPage.openAssignProxy()
    await assignProxy.selectForDefaultContainer(title)
    await helper.assertCanGetTheIpAddress()
  })

  it('should fail with incorrect SOCKS5 proxy settings', async () => {
    const helper = new Helper(geckodriver)

    const optionsPage = await helper.openOptionsPage()
    const proxyList = await optionsPage.openProxyList()
    const addProxyForm = await proxyList.openAddProxyForm()
    const title = 'Incorrectly setup SOCKS5 proxy'
    await addProxyForm.addProxy({
      title: title,
      type: 'socks',
      server: 'localhost',
      port: 999,
      username: 'user',
      password: 'password'
    })

    const assignProxy = await optionsPage.openAssignProxy()
    await assignProxy.selectForDefaultContainer(title)
    await helper.assertProxyFailure()
  })

  after(function () {
    geckodriver.quit()
  })
})

class Helper extends PageObject {
  toolbarButton = By.id('container-proxy_bekh-ivanov_me-browser-action')

  /**
   * @return {Promise<OptionsPageObject>}
   */
  async openOptionsPage() {
    await this._driver.setContext(firefox.Context.CHROME)
    await this.click(this.toolbarButton)
    await this._driver.setContext(firefox.Context.CONTENT)

    let windowHandle
    await this._driver.wait(async () => {
      const windowHandles = await this._driver.getAllWindowHandles()
      windowHandle = windowHandles[windowHandles.length - 1]
      try {
        await this._driver.switchTo().window(windowHandle)
      } catch (e) {
        return false
      }
      const title = await this._driver.getTitle()
      return title === 'Container Proxy extension settings'
    }, 2000, 'Should have opened Container Proxy extension settings')

    return this.createPageObject(OptionsPageObject)
  }

  async assertCanGetTheIpAddress() {
    await this._driver.setContext(firefox.Context.CONTENT)
    await this._driver.get('https://duckduckgo.com/?q=ip&ia=answer&atb=v150-1')
    const text = await this._driver.getPageSource()

    expect(text).to.include('Your IP address is')
  }

  async assertProxyFailure() {
    await this._driver.setContext(firefox.Context.CONTENT)
    try {
      await this._driver.get('https://api.duckduckgo.com/?q=ip&no_html=1&format=json&t=firefox-container-proxy-extension')
    } catch (e) {
    }
    const text = await this._driver.getPageSource()

    expect(text).to.include('Firefox is configured to use a proxy server that is refusing connections.')
  }
}
