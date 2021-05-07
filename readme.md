TODO: Explain to Jack how to use this repository.

For documentation of the development process, see [process.md](./process.md)

## Using the app `lofty-robot-control`

All commands in this section work in the subdirectory [lofty-robot-control](./lofty-robot-control) unless specified otherwise.

### Setup

Install Node.js from https://nodejs.org/en/download/, then run the command `npm install`.

### Building the runnable application

Running the command `npm run build` produces an HTML file that you can load in a web browser. The build process saves this file at `lofty-robot-control.html`

### Automated testing

Running the command `npm run test` runs automated tests and displays the results. It will display an output like this:

```
[...]

Running 2 tests. To reproduce these results later,
run elm-test-rs with --seed 1871523672 and --fuzz 100


TEST RUN PASSED

Duration: 4 ms
Passed:   2
Failed:   0
```

