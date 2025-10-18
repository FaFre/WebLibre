"use strict";

const { BackgroundTasksUtils } = ChromeUtils.importESModule(
  "resource://gre/modules/BackgroundTasksUtils.sys.mjs"
);

const lazy = {};

ChromeUtils.defineLazyGetter(lazy, "log", () => {
  let { ConsoleAPI } = ChromeUtils.importESModule(
    "resource://gre/modules/Console.sys.mjs"
  );
  let consoleOptions = {
    // tip: set maxLogLevel to "debug" and use log.debug() to create detailed
    // messages during development. See LOG_LEVELS in Console.sys.mjs for details.
    maxLogLevel: "error",
    maxLogLevelPref: "app.update.background.loglevel",
    prefix: "PrefsManager",
  };
  return new ConsoleAPI(consoleOptions);
});

var prefmanager = class extends ExtensionAPI {
  getAPI(context) {
    return {
      experiments: {
        prefmanager: {
          async getPrefList() {
            return Services.prefs.getChildList("");
          }
        }
      }
    };
  }
};
