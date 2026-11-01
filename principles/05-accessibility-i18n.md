# Accessibility and internationalisation

Target **WCAG 2.2 AA** on every platform. Accessibility is part of "done", not a later pass.

## Text and layout

1. **Text works at the largest text size.**
   - Resize: 200% browser zoom, and 200% text-only zoom, without loss of content or function (1.4.4).
   - Reflow: at 320 CSS px wide (400% zoom on a 1280 px screen), content fits without scrolling in two directions (1.4.10).
   - Text spacing: content survives the 1.4.12 line, letter and word spacing overrides.
2. **Size text in relative units** (`rem`, `em`), never fixed `px` that blocks text-only zoom. Fluid headings (`clamp()` with a `rem` part) may grow more slowly than body text, but still grow at 200%.
3. **Rows wrap and stack** (`04-design-and-ux.md` rule 16). Test at 200% and 400%, and reset the zoom afterwards.

## Interaction

4. **Targets**: at least 24 × 24 CSS px (2.5.8), and 44 × 44 px recommended (2.5.5) for primary and frequent actions, with spacing between them.
5. **Everything works without sight.** Each control has a role, a label and, where useful, a hint. Decorative art is hidden from screen readers. People and things are named fully: "Invoice 1042, overdue, Acme Ltd", not "image".
6. **State isn't only colour** (selected, error, required), and text contrast is at least 4.5:1 (3:1 for large text and UI parts).
7. **Keyboard and focus**: everything is reachable with Tab, focus is visible, focus moves into and back out of dialogs, and nothing traps it.
8. **Reduce motion is respected** everywhere, including entering animations, which must never leave content invisible. Test with the OS setting on (`prefers-reduced-motion: reduce`).
9. **Time limits and gestures have alternatives**: a swipe also has buttons, a long-press also has a menu item.

## Internationalisation

10. **Every user-facing string is an ICU message** in the catalogue, read through the translation function. Keys are type-checked, and lint rejects raw strings.
11. **Never build sentences by concatenation.** Use placeholders, `plural`, and `select` for grammar (`{personGrammar, select, plural {are} other {is}}` for they/them verb agreement).
12. **Pronouns come from the person's own choice**, never inferred from a name. The default is they/them.
13. **Format dates, times, numbers and units through the locale**, with the person's IANA zone (`02-architecture.md` rules 12–14). Temperature and other units follow the region unless the person chooses.
14. **Check the runtime has the Intl APIs you use.** Older browsers and some JS runtimes lack parts of `Intl` (`supportedValuesOf`, `DurationFormat`): check support for your targets, polyfill or bundle the data, and add a test that deletes the global to simulate it.
15. **Store keys, not words** (`01-engineering.md` §5), so each reader sees content in their own language.

## Audit

Run `a11y-audit` before each release and after any new screen: screen reader pass (NVDA or JAWS on Windows, VoiceOver on macOS), 200% zoom and 400% reflow, reduce motion, contrast, targets, keyboard. Findings become tickets labelled accessibility.

## Mobile (iOS and Android)

- **The largest text size is the system font size**, not zoom:
  - Android: font scale 200% (`adb shell settings put system font_scale 2.0`; reset with `1.0`).
  - iOS: the largest accessibility size, about 310%, the harder test (`xcrun simctl ui booted content_size accessibility-extra-extra-extra-large`; reset with `large`).
- **Cap display text, let body text scale.** Large decorative headings may cap their scale at about 1.4× (`maxFontSizeMultiplier={1.4}`); body text scales freely.
- **Targets**: 44 × 44 pt on iOS and 48 × 48 dp on Android, with spacing between them.
- **Screen readers**: TalkBack on Android and VoiceOver on iOS. Swipe through each screen, and check the order, labels, roles and state announcements.
- **Reduce motion**: iOS "Reduce Motion", and Android "Remove animations" (animator duration scale off).
- **Keyboards**: tablets and phones with a hardware keyboard follow rule 7.
- **Intl on Hermes**: React Native's Hermes engine lacks some `Intl` APIs (`supportedValuesOf`, sometimes `PluralRules`). Polyfill or bundle the data, and test with the global deleted.
- **Audit**: `a11y-audit` runs on both platforms with the settings above, and resets them afterwards.
