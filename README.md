# clerk

![demo](https://github.com/malcolmstill/clerk/assets/2567177/dc8f7f28-05a3-45d6-a668-a3b03484001a)

## Installation

- Download a binary for your platform from [the release page](https://github.com/malcolmstill/clerk/releases)
- linux / macos: `chmod u+x clerk`
- Ideally stick `clerk` somewhere in your `PATH`

## Dependencies

`clerk` depends on these fantastic libraries (vendored in `lib/`):
- [`zig-sqlite`](https://github.com/vrischmann/zig-sqlite)
- [`ansi-colors`](https://github.com/ziglibs/ansi-term)

## FAQ

### Where are the todos stored?

- In `~/.clerk.db`

### I'd rather compile from source than download the binaries. How do I do that?

- To build from source only requires zig 0.10.0.
- Download the source and run `zig build`
