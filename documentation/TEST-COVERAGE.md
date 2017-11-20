# Test Coverage

Measuring test coverage is a bit trickier than in normal Go tests
because the end-to-end tests of Git Town are in Ruby.


## Measuring Test Coverage

1. Compile a test binary called `git-town.test`.
   This is done via `bin/build-test`
   The test binary can be run like the production binary.
   Each time it runs, it creates a coverage file
   called `coverage.cov`.

2. Our Cucumber tests run that test binary instead of the production binary,
   thereby generating coverage data for each Cucumber scenario.
   For example, instead of running `git-town hack foo`,
   our tests now run:

   ```
   ./git-town.test -test.coverprofile=coverage.cov hack foo
   ```

3. After each scenario,
   the test framework saves the coverage file
   so that the next scenario doesn't overwrite it.

4. When all scenarios are run,
   we merge all stored coverage files together
   into the coverage file for the entire code base.

5. Travis-CI uploads that coverage file to Coveralls.io
   using [goveralls](https://github.com/mattn/goveralls).


## Viewing Test Coverage

To see the coverage, look at Coveralls.
You can also see it locally by running `bin/cuke` and then:

```
go tool cover -html=coverage.cov
```