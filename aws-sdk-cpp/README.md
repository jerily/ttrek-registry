# AWS service packages

```sh
ttrek install aws-sdk-tcl-s3 aws-sdk-tcl-dynamodb
ttrek install aws-sdk-cpp-s3
ttrek install aws-sdk-tcl-ses
```

Tcl services: `s3`, `dynamodb`, `lambda`, `sqs`, `iam`, `ssm`, `kms`, and `ses`.
C++ packages also provide `sts` and `transfer`. Tcl names and APIs are unchanged,
such as `package require awss3`. All Tcl extensions use Tcl stubs.

Each C++ service requires the exact matching `aws-sdk-cpp-core`; transfer also
requires S3. Core owns CRT libraries, core headers, and AWSSDK CMake metadata.
A small shared CMake project imports the installed dependencies and adds only
the selected upstream service directory. It neither builds nor installs core.
SDK sources are not patched. Shared and static C++ builds are supported.

The 1.11.924 service recipes opt into `unpack.shared` with the key
`aws-sdk-cpp-1.11.924`. With shared-source support in ttrek, all services reuse
one read-only SDK extraction under `ttrek-venv/build/shared-source`, keyed by
the archive's SHA-256. Each service retains its own build and log directories.
Core keeps a private SDK tree because it unpacks CRT dependencies into it.

`aws-sdk-cpp@1.11.924` and `aws-sdk-tcl@1.0.16` install the complete service set
through dependencies. Use the updated ttrek download/unpack options and
metapackage migration support when moving from a bundled installation.

The SDK and its CRT dependencies are downloaded from matching release tags.
The untagged S2N verification model is test-only and is omitted with tests off.
Update release tags and exact service dependencies together.

The upstream static core exports `ZLIB::ZLIB`; C++ consumers should call
`find_package(ZLIB REQUIRED)` before `find_package(AWSSDK ... COMPONENTS ...)`.
The Tcl build does this automatically. Static OpenSSL link dependencies are
supplied through upstream's `AWS_SDK_ADDITIONAL_LIBRARIES` CMake option.

`aws-sdk-cpp-ses@1.11.924` builds the upstream `email` component and installs
`aws-cpp-sdk-email` (headers under `aws/email`). The Tcl package is
`aws-sdk-tcl-ses@1.0.16`, providing `package require awsses`. Select `ses` with
`AWS_SDK_TCL_SERVICES`, or `email` with the upstream SDK's `BUILD_ONLY` option.
This is the SES classic API; SESv2 is a separate upstream component.
See the [SES package guide](../aws-sdk-tcl-ses/1.0.16/README.md) for installation
and a send-email example.

The Tcl 1.0.16 recipes use the `v1.0.16` source release. Existing Tcl 1.0.15
recipes remain available unchanged.
