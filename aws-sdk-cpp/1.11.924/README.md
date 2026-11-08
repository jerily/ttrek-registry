# AWS SDK for C++ 1.11.924

The release tarball omits Git submodules. This recipe restores all 15 recursive
submodules from commit-pinned tarballs into their original directories, including
S2N's nested verification model. The commits match the gitlinks in SDK tag
`1.11.924`, CRT commit `58bca57cbc8b242468414972a6a35f92676b164d`, and S2N commit
`b170000016fb44fa4dfdd86ed0b75bd28241e707`.

`SOURCE_DIR` temporarily selects each submodule's extraction directory, then is
restored before CMake runs. No Git checkout is needed. Dependencies, selected
services, and shared/static CMake options are unchanged from the 1.11.921 recipe.

For future versions, resolve the release's gitlinks recursively and update every
archive commit and destination together; do not substitute each CRT library's
latest release.
