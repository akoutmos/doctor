defmodule Mix.Tasks.DoctorTest do
  use ExUnit.Case

  setup_all do
    original_shell = Mix.shell()
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(original_shell)
    end)
  end

  describe "mix doctor" do
    test "should output the full report when no params are provided" do
      Mix.Tasks.Doctor.run([])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               [
                 "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               [
                 "Doc Cov  Spec Cov  Module                                   File                                                      Functions  No Docs  No Specs  Module Doc  Struct Spec"
               ],
               [
                 "100%     0%        Doctor.CLI                               lib/cli/cli.ex                                            3          0        3         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Config                            lib/config.ex                                             3          0        3         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.Docs                              lib/docs.ex                                               1          0        1         Yes         Yes        "
               ],
               [
                 "N/A      N/A       Doctor                                   lib/doctor.ex                                             0          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor                         lib/mix/tasks/doctor.ex                                   1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor.Explain                 lib/mix/tasks/doctor.explain.ex                           1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor.Gen.Config              lib/mix/tasks/doctor.gen.config.ex                        1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.ModuleInformation                 lib/module_information.ex                                 4          0        4         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.ModuleReport                      lib/module_report.ex                                      1          0        1         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.ReportUtils                       lib/report_utils.ex                                       9          0        9         Yes         N/A        "
               ],
               [
                 "N/A      N/A       Doctor.Reporter                          lib/reporter.ex                                           0          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Full                    lib/reporters/full.ex                                     1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Reporters.ModuleExplain           lib/reporters/module_explain.ex                           1          0        1         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Reporters.OutputUtils             lib/reporters/output_utils.ex                             6          0        6         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Short                   lib/reporters/short.ex                                    1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Summary                 lib/reporters/summary.ex                                  1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Specs                             lib/specs.ex                                              1          0        1         Yes         Yes        "
               ],
               [
                 "100%     100%      Doctor.AllDocs                           test/sample_files/all_docs.ex                             7          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.BehaviourModule                   test/sample_files/behaviour_module.ex                     3          0        0         Yes         N/A        "
               ],
               [
                 "\e[31m0%       0%        Doctor.NoDocs                            test/sample_files/no_docs.ex                              7          7        7         No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       Doctor.NoStructSpecModule                test/sample_files/no_struct_spec_module.ex                0          0        0         No          No         \e[0m"
               ],
               [
                 "\e[31m57%      57%       Doctor.PartialDocs                       test/sample_files/partial_docs.ex                         7          3        3         No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       Doctor.StructSpecModule                  test/sample_files/struct_spec_module.ex                   0          0        0         No          Yes        \e[0m"
               ],
               [
                 "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the summary report along with an error when an invalid  doctor file path is provided" do
      Mix.Tasks.Doctor.run(["--summary", "--config-file", "./not_a_real_file.exs"])
      remove_at_exit_hook()
      [[first_line] | rest_doctor_output] = get_shell_output()

      assert first_line =~ "Doctor file not found at path"
      assert first_line =~ "not_a_real_file.exs"

      assert rest_doctor_output == [
               ["---------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the summary report when a doctor file path is provided" do
      Mix.Tasks.Doctor.run(["--summary", "--config-file", "./.doctor.exs"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               ["---------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the summary report with the correct output if given the --summary flag" do
      Mix.Tasks.Doctor.run(["--summary"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               ["---------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the short report with the correct output if given the --short flag" do
      Mix.Tasks.Doctor.run(["--short"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               ["----------------------------------------------------------------------------------------------"],
               ["Doc Cov  Spec Cov  Functions  Module                                   Module Doc  Struct Spec"],
               ["100%     0%        3          Doctor.CLI                               Yes         N/A        "],
               ["100%     0%        3          Doctor.Config                            Yes         Yes        "],
               ["100%     0%        1          Doctor.Docs                              Yes         Yes        "],
               ["N/A      N/A       0          Doctor                                   Yes         N/A        "],
               ["100%     100%      1          Mix.Tasks.Doctor                         Yes         N/A        "],
               ["100%     100%      1          Mix.Tasks.Doctor.Explain                 Yes         N/A        "],
               ["100%     100%      1          Mix.Tasks.Doctor.Gen.Config              Yes         N/A        "],
               ["100%     0%        4          Doctor.ModuleInformation                 Yes         Yes        "],
               ["100%     0%        1          Doctor.ModuleReport                      Yes         Yes        "],
               ["100%     0%        9          Doctor.ReportUtils                       Yes         N/A        "],
               ["N/A      N/A       0          Doctor.Reporter                          Yes         N/A        "],
               ["100%     100%      1          Doctor.Reporters.Full                    Yes         N/A        "],
               ["100%     0%        1          Doctor.Reporters.ModuleExplain           Yes         N/A        "],
               ["100%     0%        6          Doctor.Reporters.OutputUtils             Yes         N/A        "],
               ["100%     100%      1          Doctor.Reporters.Short                   Yes         N/A        "],
               ["100%     100%      1          Doctor.Reporters.Summary                 Yes         N/A        "],
               ["100%     0%        1          Doctor.Specs                             Yes         Yes        "],
               ["100%     100%      7          Doctor.AllDocs                           Yes         N/A        "],
               ["100%     100%      3          Doctor.BehaviourModule                   Yes         N/A        "],
               [
                 "\e[31m0%       0%        7          Doctor.NoDocs                            No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       0          Doctor.NoStructSpecModule                No          No         \e[0m"
               ],
               [
                 "\e[31m57%      57%       7          Doctor.PartialDocs                       No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       0          Doctor.StructSpecModule                  No          Yes        \e[0m"
               ],
               ["----------------------------------------------------------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the full report with the correct output if given the --full flag" do
      Mix.Tasks.Doctor.run(["--full"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               [
                 "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               [
                 "Doc Cov  Spec Cov  Module                                   File                                                      Functions  No Docs  No Specs  Module Doc  Struct Spec"
               ],
               [
                 "100%     0%        Doctor.CLI                               lib/cli/cli.ex                                            3          0        3         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Config                            lib/config.ex                                             3          0        3         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.Docs                              lib/docs.ex                                               1          0        1         Yes         Yes        "
               ],
               [
                 "N/A      N/A       Doctor                                   lib/doctor.ex                                             0          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor                         lib/mix/tasks/doctor.ex                                   1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor.Explain                 lib/mix/tasks/doctor.explain.ex                           1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Mix.Tasks.Doctor.Gen.Config              lib/mix/tasks/doctor.gen.config.ex                        1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.ModuleInformation                 lib/module_information.ex                                 4          0        4         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.ModuleReport                      lib/module_report.ex                                      1          0        1         Yes         Yes        "
               ],
               [
                 "100%     0%        Doctor.ReportUtils                       lib/report_utils.ex                                       9          0        9         Yes         N/A        "
               ],
               [
                 "N/A      N/A       Doctor.Reporter                          lib/reporter.ex                                           0          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Full                    lib/reporters/full.ex                                     1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Reporters.ModuleExplain           lib/reporters/module_explain.ex                           1          0        1         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Reporters.OutputUtils             lib/reporters/output_utils.ex                             6          0        6         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Short                   lib/reporters/short.ex                                    1          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.Reporters.Summary                 lib/reporters/summary.ex                                  1          0        0         Yes         N/A        "
               ],
               [
                 "100%     0%        Doctor.Specs                             lib/specs.ex                                              1          0        1         Yes         Yes        "
               ],
               [
                 "100%     100%      Doctor.AllDocs                           test/sample_files/all_docs.ex                             7          0        0         Yes         N/A        "
               ],
               [
                 "100%     100%      Doctor.BehaviourModule                   test/sample_files/behaviour_module.ex                     3          0        0         Yes         N/A        "
               ],
               [
                 "\e[31m0%       0%        Doctor.NoDocs                            test/sample_files/no_docs.ex                              7          7        7         No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       Doctor.NoStructSpecModule                test/sample_files/no_struct_spec_module.ex                0          0        0         No          No         \e[0m"
               ],
               [
                 "\e[31m57%      57%       Doctor.PartialDocs                       test/sample_files/partial_docs.ex                         7          3        3         No          N/A        \e[0m"
               ],
               [
                 "\e[31mN/A      N/A       Doctor.StructSpecModule                  test/sample_files/struct_spec_module.ex                   0          0        0         No          Yes        \e[0m"
               ],
               [
                 "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               ["Summary:\n"],
               ["Passed Modules: 19"],
               ["Failed Modules: 4"],
               ["Total Doc Coverage: 83.1%"],
               ["Total Spec Coverage: 33.9%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end
  end

  defp get_shell_output() do
    {:messages, message_mailbox} = Process.info(self(), :messages)

    Enum.map(message_mailbox, fn
      {:mix_shell, :info, message} -> message
      {:mix_shell, :error, message} -> message
    end)
  end

  defp remove_at_exit_hook() do
    at_exit_hooks = :elixir_config.get(:at_exit)

    filtered_hooks =
      Enum.reject(at_exit_hooks, fn hook ->
        function_info = Function.info(hook)

        Keyword.get(function_info, :module) == Mix.Tasks.Doctor
      end)

    :elixir_config.put(:at_exit, filtered_hooks)
  end
end
