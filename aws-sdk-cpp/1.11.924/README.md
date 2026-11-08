# AWS SDK for C++ 1.11.924

This umbrella package installs the same nine SDK components as the earlier
bundled recipe: S3, DynamoDB, Lambda, SQS, IAM, transfer, STS, SSM, and KMS.
Its dependencies now own the libraries; the umbrella itself installs no files.

`aws-sdk-cpp-core` builds the core and all 15 pinned recursive CRT submodules
from tarballs. Each `aws-sdk-cpp-SERVICE` builds only its service against the
matching installed core. Transfer additionally depends on the S3 package.

See [service package usage](../README.md). Use a ttrek build with `fetch` and
metapackage migration support before updating an existing bundled installation.
