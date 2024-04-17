<a href="https://www.cloudmailin.com">
  <img src="https://assets.cloudmailin.com/assets/favicon.png" alt="CloudMailin Logo" height="60" align="right" title="CloudMailin">
</a>

# CloudMailin MailTools

MailTools is an SMTP client toolkit for testing SMTP servers. It's designed to
send example emails or push example raw emails to an SMTP server.

## Installation

The easiest way to install MailTools is to download it and create a symlink to
the `mailtools` script in your path.

```bash
git clone
ln -s $(pwd)/mailtools /usr/local/bin/mailtools
```

## Usage

```plaintext
Usage:
  cli send

Options:
  [--from=FROM]
                               # Default: CLI <cli@smtp>
  [--to=TO]
                               # Default: Debug <debug@smtp>
  [--cc=CC]
  [--bcc=BCC]
  [--times=N]
                               # Default: 1
  [--concurrency=N]
                               # Default: 5
  [--class=CLASS]
  [--verbose], [--no-verbose]
                               # Default: false
  [--data=DATA]
  [--headers=one two three]
  [--host=HOST]
                               # Default: localhost
  [--port=N]
                               # Default: 587
  [--username=USERNAME]
  [--password=PASSWORD]
  [--smtp-url=SMTP_URL]

Send test messages
```

### Example

```bash
mailtools send  --smtp_url "smtp://user:password@smtp-dev.local:587?starttls=true" --times 20 --concurrency=10 --headers x_cloudmta_layout=test --verbose
```
