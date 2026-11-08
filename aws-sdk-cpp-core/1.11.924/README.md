# Core and common runtime sources

The SDK release tarball omits submodules. The 15 additional `fetch` steps restore
their exact recursive gitlinks under the original source directories. The pins
come from SDK tag `1.11.924`, CRT commit
`58bca57cbc8b242468414972a6a35f92676b164d`, and S2N commit
`b170000016fb44fa4dfdd86ed0b75bd28241e707`.

Only the core package builds and installs CRT and shared AWSSDK metadata.
Service packages reuse these libraries. The patch also makes exported targets
resolve curl, OpenSSL, and zlib for static consumers.
