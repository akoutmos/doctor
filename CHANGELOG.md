# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
