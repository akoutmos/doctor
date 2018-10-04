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

## Sample report

```bash

```
