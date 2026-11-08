# AWS SDK for C++ 1.11.924

This umbrella installs S3, DynamoDB, Lambda, SQS, IAM, transfer, STS, SSM, and
KMS through individual packages. It owns no library files.

The core builds once from unmodified SDK and CRT release archives. Service
packages compile only their own sources against that installed core.
See [service package usage](../README.md).
