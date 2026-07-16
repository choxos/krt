# Security Policy

## Reporting a vulnerability

If you discover a security or privacy issue in krt (for example, a case where
sensitive ethics or consent metadata could leak into a public export, or where
an API token could be exposed), please report it privately by email to
a.sofimahmudi@gmail.com rather than opening a public issue.

Please include:

- a description of the issue and its impact;
- steps to reproduce or a proof of concept;
- any suggested remediation.

You can expect an acknowledgment within a reasonable time, and coordination on a
fix and disclosure timeline.

## Scope

krt reads and writes local files and, when explicitly asked, contacts public
registries and repositories. It never transmits a user's table to a third party
except for the specific fields required by a lookup or deposit the user invokes.
Reports about that boundary are especially welcome.
