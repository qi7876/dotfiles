# fix/config-audit-findings

## Intent

Apply the actionable configuration-audit findings without changing Kitty's
clipboard or latency policy.

## Progress

- Prevented false success output from Mihomo group selection and reload.
- Made FZF defaults stable across nested shells and repeated sourcing.
- Routed GitHub SSH through `ssh.github.com:443`.
- Simplified install and uninstall commands to full-set, no-argument operations.
- Added behavior tests for every corrected failure mode and public interface.

## Completion criteria

- Both platform configurations pass syntax and behavior tests.
- GitHub resolves to port 443.
- Repeated sourcing leaves FZF defaults unchanged.
- Install and uninstall reject all arguments before modifying the target.
