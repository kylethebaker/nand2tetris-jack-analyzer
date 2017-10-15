# JackAnalyzer

Source -> Bytecode compiler for the Jack language (_work in progress_).

## Installation

Run either `make` or `mix escript.build` to generate the executable.

## Usage

`JackAnalyzer <target> [opts]`

Where `target` is either a Jack source file with the `.jack` extension or a
directory containing Jack files. If a directory is passed then all Jack files
in the directory will be compiled.

### Options

- **--no-save-xml** - By default the parse tree will be saved with a
  `_Tree.xml` suffix in the source directory. This option disabled that.
  enabled by default.
- **--print-results** - Prints the parse tree to stdout.
- **--output-tokens** - Includes the tokens in the output, either to stdout or
  as a file with a `_Tokens.xml` suffix, depending on output options.
