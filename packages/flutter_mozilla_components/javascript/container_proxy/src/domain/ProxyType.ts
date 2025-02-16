/* eslint-disable @typescript-eslint/no-namespace,no-redeclare,import/export */

export enum ProxyType {
  Socks5 = 'socks',
  Socks4 = 'socks4',
  Http = 'http',
  Https = 'https'
}

export namespace ProxyType {
  export function tryFromString(s: string): ProxyType | undefined {
    switch (s) {
      case 'socks':
        return ProxyType.Socks5
      case 'socks4':
        return ProxyType.Socks4
      case 'http':
        return ProxyType.Http
      case 'https':
        return ProxyType.Https
      default:
        return undefined
    }
  }
}
