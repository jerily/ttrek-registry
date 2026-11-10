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

The Tcl 1.0.16 recipes use the `v1.0.16` source release. Existing Tcl 1.0.15
recipes remain available unchanged.
