# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: MIT

generate:
    cargo build --manifest-path rust/Cargo.toml && \
    dart run ffigen

format:
    cargo fmt --manifest-path rust/Cargo.toml && \
    dart format . && \
    flutter analyze
