# clerk

![demo](https://user-images.githubusercontent.com/2567177/201475799-151307c1-b41a-4d77-918e-cace181263cd.gif)

## Installation

- Download a binary for your platform from [our release page](https://github.com/malcolmstill/clerk/releases)
- linux / macos: `chmod u+x clerk`
- Ideally stick it somewhere in your `PATH`

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
