## Summary

- What changed?
- Why was it needed?

## Verification

- [ ] `dart format --set-exit-if-changed .`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build appbundle --debug`
- [ ] iOS build was checked locally when the change can affect iOS: `cd ios && pod install && cd .. && flutter build ipa --no-codesign`

## Checklist

- [ ] Scope is limited to one logical change
- [ ] Branch name follows repository rules
- [ ] CI is expected to pass with the current diff
- [ ] UI changes include screenshots or a short recording
- [ ] New commands, paths, env keys, or workflow assumptions are documented
- [ ] No secrets, certificates, provisioning profiles, or service-account files were committed
- [ ] If architecture changed, `README.md` and `CONTRIBUTING.md` were reviewed together

## Risks Or Follow-ups

- Known risk:
- Follow-up task:
