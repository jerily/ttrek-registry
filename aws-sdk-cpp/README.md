# AWS service packages

Install only the service bindings or C++ libraries you need:

```sh
ttrek install aws-sdk-tcl-s3 aws-sdk-tcl-dynamodb
ttrek install aws-sdk-cpp-s3
```

Tcl service packages are available for `s3`, `dynamodb`, `lambda`, `sqs`, `iam`,
`ssm`, and `kms`. C++ packages also include `sts` and `transfer`. Tcl package
names and APIs are unchanged, such as `package require awss3`.

Each Tcl service depends on its C++ service. Each C++ service depends on the
exact same version of `aws-sdk-cpp-core`; transfer also requires S3. The core
alone owns CRT libraries, core headers, and shared AWSSDK CMake metadata.
Service packages install their own libraries, headers, and CMake metadata.
Both shared and `-static` C++ builds are supported; Tcl modules remain shared
extensions using Tcl stubs.

`aws-sdk-cpp@1.11.924` and `aws-sdk-tcl@1.0.14` are umbrella packages preserving
the previous complete service set. Use a ttrek build containing `fetch` and
metapackage migration support. Upgrade existing umbrella packages before
mixing in individual services; older pinned monolithic releases must not be
installed alongside the split packages because they own the same paths.

All sources use tarballs. `fetch` downloads and extracts directly into a source
subdirectory without changing build environment variables. The core recipe
pins all recursive submodules to the commits in the SDK release, including
S2N's nested verification model. When updating SDK versions, update these
gitlinks and all exact-version service dependencies together. The identical
`service-packages.diff` patches keep upstream compilation and exports while
reusing installed dependencies and assigning shared metadata to the core.
