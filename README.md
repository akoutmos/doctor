# Doctor

[![Module Version](https://img.shields.io/hexpm/v/doctor.svg)](https://hex.pm/packages/doctor)
[![Build Status](https://travis-ci.org/akoutmos/doctor.svg?branch=master)](https://travis-ci.org/akoutmos/doctor)
[![Coverage Status](https://coveralls.io/repos/github/akoutmos/doctor/badge.svg?branch=master)](https://coveralls.io/github/akoutmos/doctor?branch=master)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/doctor/)
[![Total Download](https://img.shields.io/hexpm/dt/doctor.svg)](https://hex.pm/packages/doctor)
[![License](https://img.shields.io/hexpm/l/doctor.svg)](https://github.com/akoutmos/doctor/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/akoutmos/doctor.svg)](https://github.com/akoutmos/doctor/commits/master)

Ensure that your documentation is healthy with Doctor! This library contains a mix task that you can run against your
project to generate a documentation coverage report. Items which are reported on include: the presence of module docs,
which functions do/don't have docs, which functions do/don't have typespecs, and if your struct modules provide
typespecs. You can generate a `.doctor.exs` config file to specify what thresholds are acceptable for your project. If
documentation coverage drops below your specified thresholds, the `mix doctor` task will return a non zero exit status.

The primary motivation with this tool is to have something simple which can be hooked up into CI to ensure that project
documentation standards are respected and upheld. This is particular useful in a team environment when you want to
maintain a minimum threshold for documentation coverage.

## Installation

Adding `:doctor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doctor, "~> 0.18.0", only: :dev}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/doctor](https://hexdocs.pm/doctor).

## Comparison with other tools

There are a few tools in the Elixir ecosystem that overlap slightly in functionality with Doctor. It is useful for
you to know how Doctor differs from these tools and some use cases that Doctor serves.

**Credo**

[Credo](https://github.com/rrrene/credo) is a phenomenal library that can be used to perform a wide range of
static analysis checks against your codebase. It can check for lingering `IO.inspect()` statements, it can check for
unsafe atom conversions, and it can also check that the cyclomatic complexity of control statements is within a
particular range to name a few.

The one area where Doctor and Credo do overlap is that with either tool you have the capability to
enforce that `@moduledoc` attributes are present in modules. Given that this is the only overlap between the two tools,
I generally use both in my projects and perform both validations during CI/CD.

**Inch**

[Inch](https://github.com/rrrene/inch_ex) is another great tool written by René Föhring that is specifically
catered to analyzing a project's documentation (very much like Doctor). Inch will scan your project's source files and
check for the presence of function documentation and report back to you what grade it thinks your project has earned.

Inch does not appear to support checking for function typespecs, returning non-zero status codes when validation fails,
tuning thresholds via a configuration file, or checking for struct module typespecs. On the other hand, these were
things that were important to me personally and so I wrote Doctor to fill that void. In a team context, I find Doctor to
be invaluable in ensuring that a project maintains a certain level of documentation by failing CI/CD if certain
thresholds have not been met.

If I have misrepresented any of the aforementioned libraries...feel free to open up an issue :).

## Usage

Doctor comes with 2 mix tasks. One to run the documentation coverage report, and another to generate a `.doctor.exs` config file.

To run the doctor mix task and generate a report, run: `mix doctor`.
To generate a `.doctor.exs` config file with defaults, run: `mix doctor.gen.config`.
To get help documentation, run `mix help doctor` and `mix help doctor.gen.config`. The outputs of those help menus can be seen here:

Running `mix help doctor` yields:

```terminal
                                   mix doctor

Doctor is a command line utility that can be used to ensure that your project
documentation remains healthy. For more in depth documentation on Doctor or to
file bug/feature requests, please check out https://github.com/akoutmos/doctor.

The mix doctor command supports the following CLI flags (all of these options
and more are also configurable from your .doctor.exs file). The following CLI
flags are supported:

    --full       When generating a Doctor report of your project, use
                 the Doctor.Reporters.Full reporter.

    --short      When generating a Doctor report of your project, use
                 the Doctor.Reporters.Short reporter.

    --summary    When generating a Doctor report of your project, use
                 the Doctor.Reporters.Summary reporter.

    --raise      If any of your modules fails Doctor validation, then
                 raise an error and return a non-zero exit status.

    --failed     If set only the failed modules will be reported. Works with
                 --full and --short options.

    --umbrella   By default, in an umbrella project, each app will be
                 evaluated independently against the specified thresholds
                 in your .doctor.exs file. This flag changes that behavior
                 by aggregating the results of all your umbrella apps,
                 and then comparing those results to the configured
                 thresholds.
```

Running `mix help doctor.gen.config` yields:

```terminal
                             mix doctor.gen.config

Doctor is a command line utility that can be used to ensure that your project
documentation remains healthy. For more in depth documentation on Doctor or to
file bug/feature requests, please check out https://github.com/akoutmos/doctor.

The mix doctor.gen.config command can be used to create a .doctor.exs file with
the default Doctor settings. The default file contents are:

    %Doctor.Config{
      ignore_modules: [],
      ignore_paths: [],
      min_module_doc_coverage: 40,
      min_module_spec_coverage: 0,
      min_overall_doc_coverage: 50,
      min_overall_spec_coverage: 0,
      moduledoc_required: true,
      exception_moduledoc_required: true,
      raise: false,
      reporter: Doctor.Reporters.Full,
      struct_type_spec_required: true,
      umbrella: false,
      include_hidden_doc: false
    }
```

## Configuration

Below is a sample `.doctor.exs` file with some sample values for the various fields:

```elixir
%Doctor.Config{
  ignore_modules: [],
  ignore_paths: [],
  min_module_doc_coverage: 40,
  min_module_spec_coverage: 0,
  min_overall_doc_coverage: 50,
  min_overall_spec_coverage: 0,
  moduledoc_required: true,
  exception_moduledoc_required: true,
  raise: false,
  reporter: Doctor.Reporters.Full,
  struct_type_spec_required: true,
  umbrella: false,
  include_hidden_doc: false
}
```

For the reporter field, the following reporters included with Doctor:

- `Doctor.Reporters.Full`
- `Doctor.Reporters.Short`
- `Doctor.Reporters.Summary`

The `include_hidden_doc` field will mark modules as failures if it looks like:

- `@moduledoc false`

## Sample reports

Report created for Doctor itself:

```text
$ mix doctor
Doctor file found. Loading configuration.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Doc Cov  Spec Cov  Module                                   File
Functions  No Docs  No Specs  Module Doc  Struct Spec
100%     0%        Doctor.CLI                               lib/cli/cli.ex                                            2
0        2         Yes         N/A
100%     0%        Doctor.Config                            lib/config.ex                                             3
0        3         Yes         Yes
100%     0%        Doctor.Docs                              lib/docs.ex                                               1
0        1         Yes         Yes
N/A      N/A       Doctor                                   lib/doctor.ex                                             0
0        0         Yes         N/A
100%     100%      Mix.Tasks.Doctor                         lib/mix/tasks/doctor.ex                                   1
0        0         Yes         N/A
100%     0%        Mix.Tasks.Doctor.Gen.Config              lib/mix/tasks/doctor.gen.config.ex                        1
0        1         Yes         N/A
100%     0%        Doctor.ModuleInformation                 lib/module_information.ex                                 4
0        4         Yes         Yes
100%     0%        Doctor.ModuleReport                      lib/module_report.ex                                      1
0        1         Yes         Yes
100%     0%        Doctor.ReportUtils                       lib/report_utils.ex                                       9
0        9         Yes         N/A
N/A      N/A       Doctor.Reporter                          lib/reporter.ex                                           0
0        0         Yes         N/A
100%     0%        Doctor.Reporters.Full                    lib/reporters/full.ex                                     1
0        1         Yes         N/A
100%     0%        Doctor.Reporters.OutputUtils             lib/reporters/output_utils.ex                             1
0        1         Yes         N/A
100%     0%        Doctor.Reporters.Short                   lib/reporters/short.ex                                    1
0        1         Yes         N/A
100%     0%        Doctor.Reporters.Summary                 lib/reporters/summary.ex                                  1
0        1         Yes         N/A
100%     0%        Doctor.Specs                             lib/specs.ex                                              1
0        1         Yes         Yes
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:

Passed Modules: 15
Failed Modules: 0
Total Doc Coverage: 100.0%
Total Spec Coverage: 3.7%

Doctor validation has passed!
```

Report created for Phoenix:

```text
$ mix doctor
Doctor file not found. Using defaults.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Doc Cov  Spec Cov  Module                                   File                                                                  Functions  No Docs  No Specs  Module Doc
100%     0%        Mix.Phoenix                              lib/mix/phoenix.ex                                                    18         0        18        YES
0%       0%        Mix.Phoenix.Context                      lib/mix/phoenix/context.ex                                            6          6        6         YES
63%      0%        Mix.Phoenix.Schema                       lib/mix/phoenix/schema.ex                                             8          3        8         YES
100%     0%        Mix.Tasks.Compile.Phoenix                lib/mix/tasks/compile.phoenix.ex                                      2          0        2         YES
100%     0%        Mix.Tasks.Phx.Digest.Clean               lib/mix/tasks/phx.digest.clean.ex                                     1          0        1         YES
100%     0%        Mix.Tasks.Phx.Digest                     lib/mix/tasks/phx.digest.ex                                           1          0        1         YES
100%     0%        Mix.Tasks.Phx                            lib/mix/tasks/phx.ex                                                  1          0        1         YES
100%     0%        Mix.Tasks.Phx.Gen.Cert                   lib/mix/tasks/phx.gen.cert.ex                                         2          0        2         YES
100%     0%        Mix.Tasks.Phx.Gen.Channel                lib/mix/tasks/phx.gen.channel.ex                                      1          0        1         YES
86%      14%       Mix.Tasks.Phx.Gen.Context                lib/mix/tasks/phx.gen.context.ex                                      7          1        6         YES
100%     17%       Mix.Tasks.Phx.Gen.Embedded               lib/mix/tasks/phx.gen.embedded.ex                                     6          0        5         YES
100%     0%        Mix.Tasks.Phx.Gen.Html                   lib/mix/tasks/phx.gen.html.ex                                         4          0        4         YES
100%     0%        Mix.Tasks.Phx.Gen.Json                   lib/mix/tasks/phx.gen.json.ex                                         4          0        4         YES
100%     0%        Mix.Tasks.Phx.Gen.Presence               lib/mix/tasks/phx.gen.presence.ex                                     1          0        1         YES
100%     14%       Mix.Tasks.Phx.Gen.Schema                 lib/mix/tasks/phx.gen.schema.ex                                       7          0        6         YES
100%     0%        Mix.Tasks.Phx.Gen.Secret                 lib/mix/tasks/phx.gen.secret.ex                                       1          0        1         YES
100%     0%        Mix.Tasks.Phx.Routes                     lib/mix/tasks/phx.routes.ex                                           1          0        1         YES
100%     0%        Mix.Tasks.Phx.Server                     lib/mix/tasks/phx.server.ex                                           1          0        1         YES
100%     0%        Phoenix                                  lib/phoenix.ex                                                        3          0        3         YES
100%     17%       Phoenix.Channel                          lib/phoenix/channel.ex                                                12         0        10        YES
100%     18%       Phoenix.Channel.Server                   lib/phoenix/channel/server.ex                                         17         0        14        YES
100%     0%        Phoenix.CodeReloader                     lib/phoenix/code_reloader.ex                                          2          0        2         YES
40%      0%        Phoenix.CodeReloader.Proxy               lib/phoenix/code_reloader/proxy.ex                                    5          3        5         YES
33%      0%        Phoenix.CodeReloader.Server              lib/phoenix/code_reloader/server.ex                                   6          4        6         YES
88%      25%       Phoenix.Config                           lib/phoenix/config.ex                                                 8          1        6         YES
100%     52%       Phoenix.Controller                       lib/phoenix/controller.ex                                             42         0        20        YES
100%     0%        Phoenix.Controller.Pipeline              lib/phoenix/controller/pipeline.ex                                    6          0        6         YES
100%     100%      Phoenix.Digester                         lib/phoenix/digester.ex                                               2          0        0         YES
100%     0%        Phoenix.Endpoint                         lib/phoenix/endpoint.ex                                               25         0        25        YES
100%     0%        Phoenix.Endpoint.Cowboy2Adapter          lib/phoenix/endpoint/cowboy2_adapter.ex                               3          0        3         YES
0%       0%        Phoenix.Endpoint.Cowboy2Handler          lib/phoenix/endpoint/cowboy2_handler.ex                               5          5        5         YES
100%     0%        Phoenix.Endpoint.CowboyAdapter           lib/phoenix/endpoint/cowboy_adapter.ex                                2          0        2         YES
0%       0%        Phoenix.Endpoint.CowboyWebSocket         lib/phoenix/endpoint/cowboy_websocket.ex                              8          8        8         YES
100%     0%        Phoenix.Endpoint.RenderErrors            lib/phoenix/endpoint/render_errors.ex                                 3          0        3         YES
93%      0%        Phoenix.Endpoint.Supervisor              lib/phoenix/endpoint/supervisor.ex                                    15         1        15        YES
0%       0%        Phoenix.Endpoint.Watcher                 lib/phoenix/endpoint/watcher.ex                                       2          2        2         YES
NA       NA        Plug.Exception.Phoenix.ActionClauseErro  lib/phoenix/exceptions.ex                                             0          0        0         NO
NA       NA        Phoenix.NotAcceptableError               lib/phoenix/exceptions.ex                                             0          0        0         YES
100%     0%        Phoenix.MissingParamError                lib/phoenix/exceptions.ex                                             1          0        1         YES
0%       0%        Phoenix.ActionClauseError                lib/phoenix/exceptions.ex                                             2          2        2         NO
60%      0%        Phoenix.Logger                           lib/phoenix/logger.ex                                                 5          2        5         YES
83%      100%      Phoenix.Naming                           lib/phoenix/naming.ex                                                 6          1        0         YES
NA       NA        Phoenix.Param.Map                        lib/phoenix/param.ex                                                  0          0        0         NO
NA       NA        Phoenix.Param.Integer                    lib/phoenix/param.ex                                                  0          0        0         NO
NA       NA        Phoenix.Param.BitString                  lib/phoenix/param.ex                                                  0          0        0         NO
NA       NA        Phoenix.Param.Atom                       lib/phoenix/param.ex                                                  0          0        0         NO
NA       NA        Phoenix.Param.Any                        lib/phoenix/param.ex                                                  0          0        0         NO
0%       0%        Phoenix.Param                            lib/phoenix/param.ex                                                  1          1        1         YES
100%     0%        Phoenix.Presence                         lib/phoenix/presence.ex                                               17         0        17        YES
NA       NA        Phoenix.Router.NoRouteError              lib/phoenix/router.ex                                                 0          0        0         YES
100%     0%        Phoenix.Router                           lib/phoenix/router.ex                                                 11         0        11        YES
100%     0%        Phoenix.Router.ConsoleFormatter          lib/phoenix/router/console_formatter.ex                               1          0        1         YES
95%      0%        Phoenix.Router.Helpers                   lib/phoenix/router/helpers.ex                                         20         1        20        YES
100%     0%        Phoenix.Router.Resource                  lib/phoenix/router/resource.ex                                        1          0        1         YES
100%     20%       Phoenix.Router.Route                     lib/phoenix/router/route.ex                                           5          0        4         YES
100%     0%        Phoenix.Router.Scope                     lib/phoenix/router/scope.ex                                           9          0        9         YES
NA       NA        Phoenix.Socket.InvalidMessageError       lib/phoenix/socket.ex                                                 0          0        0         YES
57%      0%        Phoenix.Socket                           lib/phoenix/socket.ex                                                 14         6        14        YES
NA       NA        Phoenix.Socket.Reply                     lib/phoenix/socket/message.ex                                         0          0        0         YES
100%     0%        Phoenix.Socket.Message                   lib/phoenix/socket/message.ex                                         1          0        1         YES
NA       NA        Phoenix.Socket.Broadcast                 lib/phoenix/socket/message.ex                                         0          0        0         YES
50%      0%        Phoenix.Socket.PoolSupervisor            lib/phoenix/socket/pool_supervisor.ex                                 4          2        4         YES
NA       NA        Phoenix.Socket.Serializer                lib/phoenix/socket/serializer.ex                                      0          0        0         YES
0%       0%        Phoenix.Socket.V1.JSONSerializer         lib/phoenix/socket/serializers/v1_json_serializer.ex                  3          3        3         YES
0%       0%        Phoenix.Socket.V2.JSONSerializer         lib/phoenix/socket/serializers/v2_json_serializer.ex                  3          3        3         YES
100%     0%        Phoenix.Socket.Transport                 lib/phoenix/socket/transport.ex                                       6          0        6         YES
NA       NA        Phoenix.Template.UndefinedError          lib/phoenix/template.ex                                               0          0        0         YES
100%     45%       Phoenix.Template                         lib/phoenix/template.ex                                               11         0        6         YES
0%       0%        Phoenix.Template.EExEngine               lib/phoenix/template/eex_engine.ex                                    1          1        1         YES
NA       NA        Phoenix.Template.Engine                  lib/phoenix/template/engine.ex                                        0          0        0         YES
0%       0%        Phoenix.Template.ExsEngine               lib/phoenix/template/exs_engine.ex                                    1          1        1         YES
NA       NA        Phoenix.ChannelTest.NoopSerializer       lib/phoenix/test/channel_test.ex                                      0          0        0         YES
100%     11%       Phoenix.ChannelTest                      lib/phoenix/test/channel_test.ex                                      19         0        17        YES
100%     94%       Phoenix.ConnTest                         lib/phoenix/test/conn_test.ex                                         17         0        1         YES
100%     0%        Phoenix.Token                            lib/phoenix/token.ex                                                  2          0        2         YES
67%      0%        Phoenix.Transports.LongPoll              lib/phoenix/transports/long_poll.ex                                   3          1        3         YES
50%      0%        Phoenix.Transports.LongPoll.Server       lib/phoenix/transports/long_poll_server.ex                            4          2        4         YES
0%       0%        Phoenix.Transports.WebSocket             lib/phoenix/transports/websocket.ex                                   2          2        2         YES
100%     0%        Phoenix.View                             lib/phoenix/view.ex                                                   9          0        9         YES
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:

Passed Modules: 72
Failed Modules: 7
Total Doc Coverage: 85.1%
Total Spec Coverage: 15.3%

Doctor validation has passed!
```
