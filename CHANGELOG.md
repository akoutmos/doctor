# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Recognize `@opaque` struct typespecs.

## [0.19.0] - 2022-7-19

### Fixed

- `mix doctor.explain` now works in umbrella projects
- Properly measure documentation coverage in nested modules
- Properly measure documentation with `__using__`
- Fix `@moduledoc` detection for older elixir versions

## [0.18.0] - 2021-5-27

- @doc false assumes no explicit spec and does not count against results
- Support for using macro (thanks to @pnezis)
- No reporting of missing docs for exception modules (thanks to @pnezis)

## [0.17.0] - 2021-1-11

- Bumped up the Elixir version due to use of Mix.Task.recursing/0

## [0.16.0] - 2020-12-27

- Fixed spec coverage bug
- Added ability to filter modules using Regex

## [0.15.0] - 2020-6-23

### Added

- Added `mix doctor.explain` command so that it is easier to debug why a particular module is failing validation

### Fixed

- Modules with behaviours that are aliased were not being counted properly

## [0.14.0] - 2020-3-19

### Added

- Additional configuration option struct_type_spec_required that checks for struct module type specs

## [0.13.0] - 2020-5-20

### Fixed

- Fixed spec coverage for behavior callbacks

## [0.12.0] - 2020-3-19

### Added

- Ability to aggregate umbrella results into one report
- Ability to pass custom path to config file
- CLI docs via `mix help doctor` and `mix help doctor.gen.config`

## [0.11.0] - 2020-1-29

### Added

- Ability to pass in a file name as a string for ignore_paths

## [0.10.0] - 2019-11-20

### Added

- Ability to raise from Mix when an error is encountered

## [0.9.0] - 2019-11-11

### Fixed

- .doctor.exs file not found at root of umbrella project

## [0.8.0] - 2019-6-20

### Fixed

- Fixed Decimal math when module contains no doc coverage

## [0.7.0] - 2019-6-10

### Added

- Travis CI and tests

### Fixed

- Incorrect reporting on failed modules

## [0.6.0] - 2019-6-5

### Added

- Short reporter

### Fixed

- Incorrect spec coverage

## [0.5.0] - 2019-6-2

### Changed

- Fixed counting issue when there are multiple modules in a single file
- Changed reporters around to be more DRY and share report calculation functionality
- Added tests for Doctor reporting functionality

## [0.4.0] - 2019-1-23

### Changed

- Loaded application vs starting the application to avoid Ecto errors connecting to DB during Doctor validation

## [0.3.0] - 2018-11-30

### Changed

- Updated dependencies and fixed depreciation warning

## [0.2.0] - 2018-11-30

### Fixed

- Umbrella project exit status code

## [0.1.0] - 2018-10-04

### Added

- Initial release of Doctor.
