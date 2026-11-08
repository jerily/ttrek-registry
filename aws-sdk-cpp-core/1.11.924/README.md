# Core and common runtime releases

SDK `1.11.924` requires CRT `v0.44.2`. These tags point to the exact commits
recorded by that SDK/CRT release, preserving the recursive-clone build inputs.
All upstream downloads use tagged tar.gz archives and the sources stay unmodified.

| Dependency | Tag |
| --- | --- |
| aws-crt-cpp | `v0.44.2` |
| aws-c-auth | `v1.0.0` |
| aws-c-cal | `v1.0.0` |
| aws-c-common | `v1.0.3` |
| aws-c-compression | `v1.0.0` |
| aws-c-event-stream | `v1.0.0` |
| aws-c-http | `v1.1.0` |
| aws-c-io | `v1.1.0` |
| aws-c-mqtt | `v1.1.2` |
| aws-c-s3 | `v1.3.1` |
| aws-c-sdkutils | `v1.0.0` |
| aws-checksums | `v1.0.1` |
| aws-lc | `v5.11.0` |
| s2n | `v1.7.11` |

S2N's untagged verification model is omitted because tests are disabled.
Only this package builds core and CRT. Other services import the installed
libraries. Static OpenSSL dependencies use upstream's
`AWS_SDK_ADDITIONAL_LIBRARIES` option; consumers resolve `ZLIB::ZLIB` explicitly.
