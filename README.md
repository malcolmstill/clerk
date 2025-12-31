# clerk

![demo](https://github.com/user-attachments/assets/ba60f826-cebd-4dec-b46c-f6d79e6f6848)

## Installation

- Download a binary for your platform from [the release page](https://github.com/malcolmstill/clerk/releases)
- Supported platforms:
   - Linux
   - Windows
   - MacOS
   - FreeBSD
   - NetBSD 
- Ideally stick `clerk` somewhere in your `PATH`

## Dependencies

`clerk` depends on these fantastic libraries:
- [`zig-sqlite`](https://github.com/vrischmann/zig-sqlite)
- [`ansi-colors`](https://github.com/ziglibs/ansi-term)

## FAQ

### Where are the todos stored?

- In `~/.clerk.db`

### I'd rather compile from source than download the binaries. How do I do that?

- To build from source only requires zig 0.15.2.
- Download the source and run `zig build`
