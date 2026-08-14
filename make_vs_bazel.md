### Individual checks

| Makefile        | Bazel                                        | Note                                                   |
| --------------- | -------------------------------------------- | ------------------------------------------------------ |
| make bashism    | bazel run //:bashism                         | -                                                      |
| make shellcheck | bazel run //:shellcheck                      | -                                                      |
| make typos      | bazel run //:typos                           |                                                        |
| make all        | bazel test //:checks                         |                                                        |
| make help       | -                                            | show list of documented commands                       |
|                 | bazel query //:all                           | list every target defined in this BUILD.bazel          |
|                 | bazel test //:checks --test_output=all       | bazel test //:checks --test_output=all                 |
|                 | bazel test //:checks --test_output=errors    | only show output for failing tests                     |
|                 | bazel test //:checks --cache_test_results=no | force re-execution, ignore cache                       |
|                 | bazel clean                                  | nuke cached results/artifacts if something looks stale |
