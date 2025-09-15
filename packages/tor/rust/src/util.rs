// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: MIT

use crate::error::update_last_error;

#[no_mangle]
#[cfg(not(target_os = "windows"))]
pub unsafe extern "C" fn tor_get_nofile_limit() -> u64 {
    let nofile_limit = unwrap_or_return!(rlimit::getrlimit(rlimit::Resource::NOFILE), 0);
    nofile_limit.0
}

#[no_mangle]
#[cfg(not(target_os = "windows"))]
pub unsafe extern "C" fn tor_set_nofile_limit(limit: u64) -> u64 {
    unwrap_or_return!(rlimit::increase_nofile_limit(limit), 0)
}
