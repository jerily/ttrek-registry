# Amazon SES for Tcl

```sh
ttrek sync
ttrek install aws-sdk-tcl-ses@1.0.18
```

This installs `awsses` and the matching `aws-sdk-cpp-ses` 1.11.924 dependency,
which builds the upstream C++ SDK's `email` component. Supported operations
include text/HTML, raw MIME and templated email, template management,
identity/DKIM verification, sending quotas and statistics.

Run this Tcl code inside the installed project's environment. The SDK uses its
normal credential provider chain, including environment variables, shared AWS
credentials files, and IAM roles; do not put credentials in the script.

```tcl
package require awsses 1.0.18
set ses [::aws::ses::create {region us-east-1}]
try {
    set id [$ses send_email [dict create \
        from sender@example.com \
        to {recipient@example.com} \
        subject "Hello from Tcl" \
        text "This is a test email."]]
    puts "SES accepted message: $id"
} finally {
    $ses destroy
}
```

Use a sender identity verified in the selected region. While the account is in
the SES sandbox, recipients must also be verified or use an SES mailbox simulator
address. The caller needs `ses:SendEmail` permission for the sending identity and
network access to the SES API. An isolated VPC needs an API interface endpoint
or internet egress; an SMTP endpoint does not serve these API requests.

For an existing configuration set, add `configuration_set your-set-name` to the
message dictionary. The package does not provision identities, DNS, IAM, or
network resources; manage those in your application's infrastructure.

See the [versioned API reference](https://github.com/jerily/aws-sdk-tcl/blob/v1.0.18/src/aws-sdk-tcl-ses/readme.md)
and [standalone example](https://github.com/jerily/aws-sdk-tcl/blob/v1.0.18/examples/ses.tcl).
