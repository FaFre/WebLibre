// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: MIT

use crate::error::update_last_error;
use arti_client::config::pt::TransportConfigBuilder;
use arti_client::config::CfgPath;
use arti_client::{DormantMode, TorClient, TorClientConfig};
use lazy_static::lazy_static;
use std::ffi::{c_char, c_void, CStr};
use std::net::SocketAddr;
use std::{io, ptr};
use tokio::runtime::{Builder, Runtime};
use tokio::task::JoinHandle;
use tor_config::Listen;
use tor_rtcompat::tokio::TokioNativeTlsRuntime;
use tor_rtcompat::ToplevelBlockOn;

pub use crate::error::tor_last_error_message;
#[cfg(not(target_os = "windows"))]
pub use crate::util::tor_get_nofile_limit;
#[cfg(not(target_os = "windows"))]
pub use crate::util::tor_set_nofile_limit;

#[macro_use]
mod error;
mod util;

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

#[repr(C)]
pub struct Tor {
    client: *mut c_void,
    proxy: *mut c_void,
}

struct TorConfig {
    state_dir: String,
    cache_dir: String,
    obfs4_port: u16,
    snowflake_port: u16,
    bridge_lines: Option<String>,
}

fn build_tor_client_config(
    config: &TorConfig,
) -> Result<TorClientConfig, tor_config::ConfigBuildError> {
    let mut cfg_builder = TorClientConfig::builder();

    cfg_builder
        .storage()
        .state_dir(CfgPath::new(config.state_dir.clone()))
        .cache_dir(CfgPath::new(config.cache_dir.clone()));

    cfg_builder.address_filter().allow_onion_addrs(false);

    if config.obfs4_port > 0 {
        let mut transport = TransportConfigBuilder::default();
        transport
            .protocols(vec!["obfs4".parse().unwrap()])
            .proxy_addr(SocketAddr::new(
                "127.0.0.1".parse().unwrap(),
                config.obfs4_port,
            ));
        cfg_builder.bridges().transports().push(transport);
    }

    if config.snowflake_port > 0 {
        let mut transport = TransportConfigBuilder::default();
        transport
            .protocols(vec!["snowflake".parse().unwrap()])
            .proxy_addr(SocketAddr::new(
                "127.0.0.1".parse().unwrap(),
                config.snowflake_port,
            ));
        cfg_builder.bridges().transports().push(transport);
    }

    if let Some(ref bridge_lines) = config.bridge_lines {
        for bridge_line in bridge_lines.split('\n') {
            match bridge_line.parse() {
                Ok(bridge) => {
                    cfg_builder.bridges().bridges().push(bridge);
                }
                Err(e) => {
                    eprintln!("Failed to parse bridge line '{}': {}", bridge_line, e);
                }
            }
        }
    }

    cfg_builder.build()
}

unsafe fn parse_config_from_c_params(
    state_dir: *const c_char,
    cache_dir: *const c_char,
    obfs4_port: u16,
    snowflake_port: u16,
    bridge_lines: *const c_char,
) -> Result<TorConfig, std::str::Utf8Error> {
    let state_dir = CStr::from_ptr(state_dir).to_str()?.to_owned();
    let cache_dir = CStr::from_ptr(cache_dir).to_str()?.to_owned();

    let bridge_lines = if bridge_lines.is_null() {
        None
    } else {
        Some(CStr::from_ptr(bridge_lines).to_str()?.to_owned())
    };

    Ok(TorConfig {
        state_dir,
        cache_dir,
        obfs4_port,
        snowflake_port,
        bridge_lines,
    })
}

#[no_mangle]
pub unsafe extern "C" fn tor_start(
    socks_port: u16,
    state_dir: *const c_char,
    cache_dir: *const c_char,
    obfs4_port: u16,
    snowflake_port: u16,
    bridge_lines: *const c_char,
) -> Tor {
    let err_ret = Tor {
        client: ptr::null_mut(),
        proxy: ptr::null_mut(),
    };

    let config = unwrap_or_return!(
        parse_config_from_c_params(
            state_dir,
            cache_dir,
            obfs4_port,
            snowflake_port,
            bridge_lines
        ),
        err_ret
    );

    let runtime = unwrap_or_return!(TokioNativeTlsRuntime::create(), err_ret);
    let cfg = unwrap_or_return!(build_tor_client_config(&config), err_ret);

    let client = unwrap_or_return!(
        runtime.block_on(async {
            TorClient::with_runtime(runtime.clone())
                .config(cfg)
                .create_bootstrapped()
                .await
        }),
        err_ret
    );

    let proxy_handle_box = Box::new(start_proxy(socks_port, client.clone()));
    let client_box = Box::new(client.clone());

    Tor {
        client: Box::into_raw(client_box) as *mut c_void,
        proxy: Box::into_raw(proxy_handle_box) as *mut c_void,
    }
}

#[no_mangle]
pub unsafe extern "C" fn tor_reconfigure(
    client: *mut c_void,
    state_dir: *const c_char,
    cache_dir: *const c_char,
    obfs4_port: u16,
    snowflake_port: u16,
    bridge_lines: *const c_char,
) -> bool {
    let config = unwrap_or_return!(
        parse_config_from_c_params(
            state_dir,
            cache_dir,
            obfs4_port,
            snowflake_port,
            bridge_lines
        ),
        false
    );

    let cfg = unwrap_or_return!(build_tor_client_config(&config), false);

    let client = {
        assert!(!client.is_null());
        Box::from_raw(client as *mut TorClient<TokioNativeTlsRuntime>)
    };

    unwrap_or_return!(
        TorClient::reconfigure(&client, &cfg, tor_config::Reconfigure::WarnOnFailures),
        false
    );

    Box::leak(client);
    true
}

#[no_mangle]
pub unsafe extern "C" fn tor_client_bootstrap(client: *mut c_void) -> bool {
    let client = {
        assert!(!client.is_null());
        Box::from_raw(client as *mut TorClient<TokioNativeTlsRuntime>)
    };

    unwrap_or_return!(client.runtime().block_on(client.bootstrap()), false);
    true
}

#[no_mangle]
pub unsafe extern "C" fn tor_client_set_dormant(client: *mut c_void, soft_mode: bool) {
    let client = {
        assert!(!client.is_null());
        Box::from_raw(client as *mut TorClient<TokioNativeTlsRuntime>)
    };

    let dormant_mode = if soft_mode {
        DormantMode::Soft
    } else {
        DormantMode::Normal
    };
    client.set_dormant(dormant_mode);
    Box::leak(client);
}

#[no_mangle]
pub unsafe extern "C" fn tor_proxy_stop(proxy: *mut c_void) {
    let proxy = {
        assert!(!proxy.is_null());
        Box::from_raw(proxy as *mut JoinHandle<anyhow::Result<()>>)
    };

    proxy.abort();
}

fn start_proxy(
    port: u16,
    client: TorClient<TokioNativeTlsRuntime>,
) -> JoinHandle<anyhow::Result<()>> {
    println!("Starting proxy!");
    let rt = RUNTIME.as_ref().unwrap();
    rt.spawn(arti::proxy::run_proxy(
        client.runtime().clone(),
        client.clone(),
        Listen::new_localhost(port),
        None,
    ))
}

#[no_mangle]
pub unsafe extern "C" fn tor_hello() {
    println!("HELLO THERE");
}
