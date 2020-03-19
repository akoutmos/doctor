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
                 "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               [
                 "Doc Cov  Spec Cov  Module                                   File                                                                  Functions  No Docs  No Specs  Module Doc"
               ],
               [
                 "100%     0%        Doctor.CLI                               lib/cli/cli.ex                                                        2          0        2         YES       "
               ],
               [
                 "100%     0%        Doctor.Config                            lib/config.ex                                                         3          0        3         YES       "
               ],
               [
                 "100%     0%        Doctor.Docs                              lib/docs.ex                                                           1          0        1         YES       "
               ],
               [
                 "NA       NA        Doctor                                   lib/doctor.ex                                                         0          0        0         YES       "
               ],
               [
                 "100%     0%        Mix.Tasks.Doctor                         lib/mix/tasks/doctor.ex                                               1          0        1         YES       "
               ],
               [
                 "100%     0%        Mix.Tasks.Doctor.Gen.Config              lib/mix/tasks/doctor.gen.config.ex                                    1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.ModuleInformation                 lib/module_information.ex                                             3          0        3         YES       "
               ],
               [
                 "100%     0%        Doctor.ModuleReport                      lib/module_report.ex                                                  1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.ReportUtils                       lib/report_utils.ex                                                   9          0        9         YES       "
               ],
               [
                 "NA       NA        Doctor.Reporter                          lib/reporter.ex                                                       0          0        0         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Full                    lib/reporters/full.ex                                                 1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.OutputUtils             lib/reporters/output_utils.ex                                         1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Short                   lib/reporters/short.ex                                                1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Summary                 lib/reporters/summary.ex                                              1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Specs                             lib/specs.ex                                                          1          0        1         YES       "
               ],
               [
                 "100%     100%      Doctor.AllDocs                           test/sample_files/all_docs.ex                                         7          0        0         YES       "
               ],
               [
                 "\e[31m0%       0%        Doctor.NoDocs                            test/sample_files/no_docs.ex                                          7          7        7         NO        \e[0m"
               ],
               [
                 "\e[31m57%      57%       Doctor.PartialDocs                       test/sample_files/partial_docs.ex                                     7          3        3         NO        \e[0m"
               ],
               [
                 "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               ["Summary:\n"],
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the summary report along with an error when an invalid  doctor file path is provided" do
      Mix.Tasks.Doctor.run(["--summary", "--config-file", "./not_a_real_file.exs"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               [
                 "Doctor file not found at path \"/home/akoutmos/Documents/open_source_libs/doctor/not_a_real_file.exs\". Using defaults."
               ],
               ["---------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
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
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
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
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
               ["\e[31mDoctor validation has failed!\e[0m"]
             ]
    end

    test "should output the short report with the correct output if given the --short flag" do
      Mix.Tasks.Doctor.run(["--short"])
      remove_at_exit_hook()
      doctor_output = get_shell_output()

      assert doctor_output == [
               ["Doctor file found. Loading configuration."],
               ["---------------------------------------------------------------------------------"],
               ["Doc Cov  Spec Cov  Functions  Module                                   Module Doc"],
               ["100%     0%        2          Doctor.CLI                               YES       "],
               ["100%     0%        3          Doctor.Config                            YES       "],
               ["100%     0%        1          Doctor.Docs                              YES       "],
               ["NA       NA        0          Doctor                                   YES       "],
               ["100%     0%        1          Mix.Tasks.Doctor                         YES       "],
               ["100%     0%        1          Mix.Tasks.Doctor.Gen.Config              YES       "],
               ["100%     0%        3          Doctor.ModuleInformation                 YES       "],
               ["100%     0%        1          Doctor.ModuleReport                      YES       "],
               ["100%     0%        9          Doctor.ReportUtils                       YES       "],
               ["NA       NA        0          Doctor.Reporter                          YES       "],
               ["100%     0%        1          Doctor.Reporters.Full                    YES       "],
               ["100%     0%        1          Doctor.Reporters.OutputUtils             YES       "],
               ["100%     0%        1          Doctor.Reporters.Short                   YES       "],
               ["100%     0%        1          Doctor.Reporters.Summary                 YES       "],
               ["100%     0%        1          Doctor.Specs                             YES       "],
               ["100%     100%      7          Doctor.AllDocs                           YES       "],
               ["\e[31m0%       0%        7          Doctor.NoDocs                            NO        \e[0m"],
               ["\e[31m57%      57%       7          Doctor.PartialDocs                       NO        \e[0m"],
               ["---------------------------------------------------------------------------------"],
               ["Summary:\n"],
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
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
                 "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               [
                 "Doc Cov  Spec Cov  Module                                   File                                                                  Functions  No Docs  No Specs  Module Doc"
               ],
               [
                 "100%     0%        Doctor.CLI                               lib/cli/cli.ex                                                        2          0        2         YES       "
               ],
               [
                 "100%     0%        Doctor.Config                            lib/config.ex                                                         3          0        3         YES       "
               ],
               [
                 "100%     0%        Doctor.Docs                              lib/docs.ex                                                           1          0        1         YES       "
               ],
               [
                 "NA       NA        Doctor                                   lib/doctor.ex                                                         0          0        0         YES       "
               ],
               [
                 "100%     0%        Mix.Tasks.Doctor                         lib/mix/tasks/doctor.ex                                               1          0        1         YES       "
               ],
               [
                 "100%     0%        Mix.Tasks.Doctor.Gen.Config              lib/mix/tasks/doctor.gen.config.ex                                    1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.ModuleInformation                 lib/module_information.ex                                             3          0        3         YES       "
               ],
               [
                 "100%     0%        Doctor.ModuleReport                      lib/module_report.ex                                                  1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.ReportUtils                       lib/report_utils.ex                                                   9          0        9         YES       "
               ],
               [
                 "NA       NA        Doctor.Reporter                          lib/reporter.ex                                                       0          0        0         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Full                    lib/reporters/full.ex                                                 1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.OutputUtils             lib/reporters/output_utils.ex                                         1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Short                   lib/reporters/short.ex                                                1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Reporters.Summary                 lib/reporters/summary.ex                                              1          0        1         YES       "
               ],
               [
                 "100%     0%        Doctor.Specs                             lib/specs.ex                                                          1          0        1         YES       "
               ],
               [
                 "100%     100%      Doctor.AllDocs                           test/sample_files/all_docs.ex                                         7          0        0         YES       "
               ],
               [
                 "\e[31m0%       0%        Doctor.NoDocs                            test/sample_files/no_docs.ex                                          7          7        7         NO        \e[0m"
               ],
               [
                 "\e[31m57%      57%       Doctor.PartialDocs                       test/sample_files/partial_docs.ex                                     7          3        3         NO        \e[0m"
               ],
               [
                 "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               ],
               ["Summary:\n"],
               ["Passed Modules: 16"],
               ["Failed Modules: 2"],
               ["Total Doc Coverage: 78.7%"],
               ["Total Spec Coverage: 23.4%\n"],
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
