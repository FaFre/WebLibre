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
          async resetPrefs(prefNames) {
            if (prefNames && prefNames.length > 0) {
              for (const prefName of prefNames) {
                Services.prefs.clearUserPref(prefName);
              }
            } else {
              Services.prefs.resetPrefs();
            }
          },
          async getPrefs(prefNames) {
            const prefs = (prefNames && prefNames.length > 0)
              ? prefNames
              : Services.prefs.getChildList("");

            const result = {};

            for (const prefName of prefs) {
              try {
                switch (Services.prefs.getPrefType(prefName)) {
                  case Services.prefs.PREF_BOOL:
                    result[prefName] = Services.prefs.getBoolPref(prefName);
                    break;
                  case Services.prefs.PREF_INT:
                    result[prefName] = Services.prefs.getIntPref(prefName);
                    break;
                  case Services.prefs.PREF_STRING:
                    result[prefName] = Services.prefs.getCharPref(prefName);
                    break;
                  default:
                    // Skip complex values or invalid preferences
                    continue;
                }
              } catch (e) {
                lazy.log.error(`Error reading preference ${prefName}: ${e}`);
                continue;
              }
            }

            lazy.log.debug(`getAll: retrieved ${Object.keys(result).length} preferences`);
            return result;
          },
          async parsePrefsAndApply(prefsFileContent, predicate = null) {
            let prefs = {};
            let addPref = (kind, name, value) => {
              if (predicate && !predicate(name)) {
                return;
              }
              prefs[name] = value;
            };

            Services.prefs.parsePrefsFromBuffer(
              prefsFileContent,
              {
                onStringPref: addPref,
                onIntPref: addPref,
                onBoolPref: addPref,
                onError(message) {
                  throw new Error(
                    `Error parsing preferences "${message}"`
                  );
                },
              },
            );

            await BackgroundTasksUtils.withProfileLock(profileLock => {
              for (let [name, value] of Object.entries(prefs)) {
                switch (typeof value) {
                  case "boolean":
                    Services.prefs.setBoolPref(name, value);
                    break;
                  case "number":
                    Services.prefs.setIntPref(name, value);
                    break;
                  case "string":
                    Services.prefs.setCharPref(name, value);
                    break;
                  default:
                    throw new Error(
                      `Pref from default profile with name "${name}" has unrecognized type`
                    );
                }
              }
            });

            lazy.log.debug(`applyPreferences: parsed prefs from buffer`, prefs);
            return prefs;
          }
        }
      }
    };
  }
};
