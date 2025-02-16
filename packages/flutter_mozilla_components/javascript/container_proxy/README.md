[![Join the chat at https://gitter.im/firefox-container-proxy/community](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/firefox-container-proxy/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![CircleCI](https://circleci.com/gh/bekh6ex/firefox-container-proxy/tree/master.svg?style=svg)](https://circleci.com/gh/bekh6ex/firefox-container-proxy/tree/master)
[![Translation status](https://hosted.weblate.org/widgets/firefox-container-proxy/-/firefox-container-proxy/svg-badge.svg)](https://hosted.weblate.org/engage/firefox-container-proxy/)


[Extension page](https://addons.mozilla.org/en-US/firefox/addon/container-proxy/)

## Permissions

  * **cookies**: needed to identify to which container request belongs
  * **webRequest** and  **webRequestBlocking**: to supply credentials for proxy authorization (but not for normal web authorization)

## Good to know

There is a known issue with DNS leak happening in non-default containers when uBlock is installed. The issue is not resolvable by this extension, but can be resolved adjusting in uBlock settings. See [comment](https://github.com/bekh6ex/firefox-container-proxy/issues/23#issuecomment-773249909)

## Translation
[![Translation status](https://hosted.weblate.org/widgets/firefox-container-proxy/-/firefox-container-proxy/multi-auto.svg)](https://hosted.weblate.org/engage/firefox-container-proxy/)

[Translate to your language](https://hosted.weblate.org/engage/firefox-container-proxy/)
