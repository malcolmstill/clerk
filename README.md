# Clerk

![output](https://user-images.githubusercontent.com/2567177/199856202-68d1e750-12d9-4d1b-868a-280ceab34e4f.gif)

## Installation

Download a binary for your platform from [our release page](https://github.com/malcolmstill/clerk/releases)

## Dependencies

`clerk` depends on these fantastic libraries (vendored in `lib/`):
- [`zig-sqlite`](https://github.com/vrischmann/zig-sqlite)
- [`ansi-colors`](https://github.com/ziglibs/ansi-term)

## FAQ

### I'd rather compile from source than download the binaries. How do I do that?

- To build from source only requires zig 0.10.0.
- Download the source and run `zig build`