# JobWorth native iOS release candidate (scaffold)

This is a **SwiftUI/StoreKit 2 starting point**, NOT a compiled, tested, App Store-ready app. It does not yet reproduce every web feature. Keep the current approved web UI as the reference.

## Build setup
1. On a Mac with a supported Xcode version, create a new iOS SwiftUI App named JobWorth.
2. Replace the generated app entry file with JobWorthApp.swift.
3. Set a unique bundle identifier owned by the developer and configure signing.
4. In App Store Connect, create a non-consumable in-app purchase and make its product ID match the source. Do not assume the placeholder ID is available.
5. Use StoreKit configuration in Xcode to test buy, cancel, pending, restore, revoked and interrupted transactions.
6. Complete the web-to-native feature parity checklist before submitting to TestFlight.
7. Never claim device tests or Apple submission are complete without evidence.

## Release blockers
- Full parity for Fix This Job, What If, overhead, forgotten costs, comparison, history, export, saved pricing assumptions.
- Harden decimal/currency validation and calculate independently tested reference fixtures.
- Full VoiceOver, Dynamic Type, reduced-motion and iPhone size checks.
- StoreKit product setup, sandbox purchase and restore acceptance.
- Privacy policy, support URL, screenshots, app icon, product descriptions, age rating, App Privacy answers.
- Real Xcode build, TestFlight install and physical-device acceptance.

The free tier calculates profit/margin; the proposed lifetime Pro price is $14.99, subject to final App Store Connect setup and approval.
