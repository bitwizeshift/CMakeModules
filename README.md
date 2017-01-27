# `bit::cmake`

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/bitwizeshift/Lazy/master/LICENSE.md)

## What is `bit::cmake`?

This is a small repo that contains some cmake build modules and toolchains to facilitate easier script writing. 
These are used in various personal projects to promote writing c++ that follows proper coding standards

## Modules

Currently, there are only 3 available cmake modules, described below.

### `add_cxx_independence_test`

This cmake command creates a custom library that generate a list of source files that include each header individually.
The purpose of this is to ensure that each header in a public API requires no header-ordering to properly operate.

### `add_header_library`

A wrapper around `add_cxx_independence_test` and `add_library` that creates both an external interface target, and an internal independence test target.
This provides a PRE_BUILD and a POST_BUILD step for interface libraries, while ensuring that interface libraries are well-formed.

Otherwise, standard cmake INTERFACE libraries provide no proper analysis of header libraries, since headers do not compile.

### `add_cxx_test`

This is a small wrapper around `add_executable` that immediately invokes the built binary after building it. This allows
chaining dependencies, and breaking builds on unit test failures
