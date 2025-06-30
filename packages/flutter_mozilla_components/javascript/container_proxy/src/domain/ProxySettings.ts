import { ProxyType } from './ProxyType'
import { ProxyDao } from '../store/Store'
import { HttpProxyInfo, HttpsProxyInfo, ProxyInfo, Socks4ProxyInfo, Socks5ProxyInfo } from './ProxyInfo'

/* eslint-disable @typescript-eslint/no-namespace,@typescript-eslint/no-redeclare */

export type ProxySettings = Socks4ProxySettings | Socks5ProxySettings | HttpProxySettings | HttpsProxySettings

const failoverTimeout = 5

export namespace ProxySettings {

  export function tryFromDao(dao: ProxyDao): ProxySettings | undefined {
    switch (dao.type) {
      case 'socks':
        return new Socks5ProxySettings(dao)
      case 'socks4':
        return new Socks4ProxySettings(dao)
      case 'http':
        return new HttpProxySettings(dao)
      case 'https':
        return new HttpsProxySettings(dao)
      default:
        return undefined
    }
  }
}

abstract class ProxySettingsBase<PI extends ProxyInfo> {
  readonly id: string
  readonly title: string
  readonly host: string
  readonly port: number
  readonly doNotProxyLocal: boolean

  protected constructor(dao: ProxyDao) {
    this.id = dao.id
    this.title = dao.title
    this.host = dao.host
    this.port = dao.port
    this.doNotProxyLocal = dao.doNotProxyLocal
  }

  abstract get type(): PI['type']

  abstract asProxyInfo(): PI

  abstract asDao(): ProxyDao

  get url(): string {
    return `${this.type}://${this.host}:${this.port}`
  }

  protected baseDao(): ProxyDao {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      host: this.host,
      port: this.port,
      doNotProxyLocal: this.doNotProxyLocal
    }
  }
}

export class Socks5ProxySettings extends ProxySettingsBase<Socks5ProxyInfo> {
  readonly username?: string
  readonly password?: string
  readonly proxyDNS: boolean

  constructor(dao: ProxyDao) {
    super(dao)
    this.username = dao.username
    this.password = dao.password
    this.proxyDNS = dao.proxyDNS ?? true
  }

  get type(): ProxyType.Socks5 {
    return ProxyType.Socks5
  }

  asProxyInfo(): Socks5ProxyInfo {
    return {
      type: this.type,
      host: this.host,
      port: this.port,
      username: this.username ?? '',
      password: this.password ?? '',
      proxyDNS: this.proxyDNS,
      failoverTimeout
    }
  }

  asDao(): ProxyDao {
    return { ...super.baseDao(), username: this.username, password: this.password, proxyDNS: this.proxyDNS }
  }
}

export class Socks4ProxySettings extends ProxySettingsBase<Socks4ProxyInfo> {
  readonly proxyDNS: boolean

  constructor(dao: ProxyDao) {
    super(dao)
    this.proxyDNS = dao.proxyDNS ?? true
  }

  get type(): ProxyType.Socks4 {
    return ProxyType.Socks4
  }

  asProxyInfo(): Socks4ProxyInfo {
    return {
      type: this.type,
      host: this.host,
      port: this.port,
      proxyDNS: this.proxyDNS,
      failoverTimeout
    }
  }

  asDao(): ProxyDao {
    return { ...super.baseDao(), proxyDNS: this.proxyDNS }
  }
}

abstract class HttpBasedProxySettings<PI extends (HttpsProxyInfo | HttpProxyInfo)> extends ProxySettingsBase<PI> {
  readonly username?: string
  readonly password?: string

  constructor(dao: ProxyDao) {
    super(dao)
    this.username = dao.username
    this.password = dao.password
  }

  asDao(): ProxyDao {
    return { ...super.baseDao(), username: this.username, password: this.password }
  }
}

export class HttpsProxySettings extends HttpBasedProxySettings<HttpsProxyInfo> {
  get type(): ProxyType.Https {
    return ProxyType.Https
  }

  asProxyInfo(): HttpsProxyInfo {
    return {
      type: this.type,
      host: this.host,
      port: this.port,
      proxyAuthorizationHeader: '', //generateAuthorizationHeader(this.username ?? '', this.password ?? ''),
      failoverTimeout
    }
  }
}

export class HttpProxySettings extends HttpBasedProxySettings<HttpProxyInfo> {
  get type(): ProxyType.Http {
    return ProxyType.Http
  }

  asProxyInfo(): HttpProxyInfo {
    return {
      type: this.type,
      host: this.host,
      port: this.port,
      failoverTimeout
    }
  }
}
