# Doctor

[![Hex.pm](https://img.shields.io/hexpm/v/doctor.svg)](http://hex.pm/packages/doctor)

**WORK IN PROGRESS**

Ensure that your documentation is healthy with Doctor! This library contains a mix task which you can run against your project to generate a documentation coverage report. Items which are reported on include: the presence of module docs, which functions don't have docs, and which functions don't have type specs. You can generate a `.doctor.exs` config file to specify what thresholds are acceptable for your project. If documentation coverage drops below your specified thresholds, the `mix doctor` task will return a non zero exit status.

The primary motivation with this tool is to have something simple which can be hooked up into CI to ensure that project documentation standards are respected.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `doctor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doctor, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/doctor](https://hexdocs.pm/doctor).

## Usage

Doctor comes with 2 mix tasks. One to run the documentation coverage report, and another to generate a `.doctor.exs` config file.

To run the doctor mix task and generate a report run: `mix doctor`
To generate a `.doctor.exs` config file with defaults, run: `mix doctor.gen.config`

## Sample report

```bash
Doctor file found. Loading configuration.
-----------------------------------------------------------------------------------------------------------------
DOC_COV SPEC_COV FILE                                               FUNCTIONS MISSED_DOCS MISSED_SPECS MODULE_DOC
0%      0%       lib/cli/cli.ex                                     1         1           1            YES
0%      0%       lib/config.ex                                      3         3           3            NO
0%      0%       lib/docs.ex                                        1         1           1            YES
NA      NA       lib/doctor.ex                                      0         0           0            YES
0%      0%       lib/mix/tasks/doctor.ex                            1         1           1            NO
0%      0%       lib/mix/tasks/doctor.gen.config.ex                 1         1           1            NO
33%     0%       lib/module_information.ex                          3         2           3            YES
0%      0%       lib/module_report.ex                               1         1           1            NO
NA      NA       lib/reporter.ex                                    0         0           0            NO
0%      0%       lib/reporters/full.ex                              1         1           1            NO
0%      0%       lib/reporters/summary.ex                           1         1           1            NO
0%      0%       lib/specs.ex                                       1         1           1            YES
-----------------------------------------------------------------------------------------------------------------
Summary:

Passed Modules: 1
Failed Modules: 11
Total Doc Coverage: 2.8%
Total Spec Coverage: 0.0%

Doctor validation has failed!
```
