# End-to-End Testing

This package uses [Terratest](https://terratest.gruntwork.io) for automatic/E2E 
testing.

To run tests:

```bash
export GOOGLE_PROJECT='test-terraform-project-01'
export GOOGLE_CREDENTIALS=$(<GCP_SERVICE_ACCOUNT_KEYFILE.JSON)
go test -v -timeout 30m
```

Tests should always be performed in a separate project (and a separate account, 
if possible) to completely isolate live environments from any potential issues.