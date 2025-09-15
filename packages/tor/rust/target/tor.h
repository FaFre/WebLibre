#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct Tor {
  void *client;
  void *proxy;
} Tor;

struct Tor tor_start(uint16_t socks_port,
                     const char *state_dir,
                     const char *cache_dir,
                     uint16_t obfs4_port,
                     uint16_t snowflake_port,
                     const char *bridge_lines);

bool tor_reconfigure(void *client,
                     const char *state_dir,
                     const char *cache_dir,
                     uint16_t obfs4_port,
                     uint16_t snowflake_port,
                     const char *bridge_lines);

bool tor_client_bootstrap(void *client);

void tor_client_set_dormant(void *client, bool soft_mode);

void tor_proxy_stop(void *proxy);

void tor_hello(void);

const char *tor_last_error_message(void);

uint64_t tor_get_nofile_limit(void);

uint64_t tor_set_nofile_limit(uint64_t limit);
