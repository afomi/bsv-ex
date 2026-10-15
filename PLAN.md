# PLAN

Work through tasks in order. Each task is a user-story scenario with at least one corresponding test.

---

## Chronicle SIGHASH + malleability (remaining from 2026-04-13 handoff)

Branch: `chronicle-opcodes` (off `update-2026-04`). No Chronicle flag — library unconditionally implements Chronicle semantics. See `.claude/inbox/done/2026-04-13-chronicle-support.md` for prior opcode work (commit `7919aab`). See `.claude/inbox/2026-04-13-chronicle-sighash-and-malleability.md` for full context and node references.

### Task 1 — Add SIGHASH_CHRONICLE flag constant and guard

**As a** transaction signer
**I want** to detect when a sighash byte has the Chronicle bit (`0x20`) set
**So that** the signing pipeline can route to the OTDA preimage builder

**Acceptance:**
- `BSV.Sig.sighash_flag(:sighash_chronicle)` returns `0x20`
- `BSV.Sig.sighash_chronicle?(0x20)` returns `true`
- `BSV.Sig.sighash_chronicle?(0x40)` returns `false` (forkid bit only)
- `BSV.Sig.sighash_chronicle?(0x60)` returns `true` (both bits set)

**Test:** `test/bsv/sig_test.exs` — describe "sighash_chronicle? guard" with the four cases above.

**Non-goal:** do NOT add CHRONICLE to `@default_sighash`. Chronicle is opt-in per the spec.

---

### Task 2 — Implement OTDA preimage builder

**As a** transaction signer opting into Chronicle
**I want** to compute a signature preimage using the Original Transaction Digest Algorithm
**So that** I can produce signatures valid under BSV Chronicle consensus

**Acceptance:**
- New function `BSV.Sig.otda_preimage/4` (or private helper reached via `preimage/4` dispatch). Keep separate from the BIP143 `preimage/4` body — do NOT unify.
- Preimage matches bytes produced by the BSV node for the same `(tx, vin, prev_txout, sighash_type)` inputs.
- Preimage construction matches pre-BIP143 Satoshi algorithm: serialize the whole tx, zero all input scripts except the subject input (which gets the subscript), append sighash type.

**Test:** `test/bsv/sig_test.exs` — describe "OTDA preimage" with fixtures lifted from `bitcoin-sv/src/test/sighash_tests.cpp`. At minimum 3 vectors covering SIGHASH_ALL | CHRONICLE, SIGHASH_NONE | CHRONICLE, SIGHASH_SINGLE | CHRONICLE. Do not handwrite vectors.

**Review gate:** run `/codex review` or Claude adversarial subagent on the sig.ex diff before commit. Crypto correctness, no shortcuts.

---

### Task 3 — Route sighash dispatch to OTDA when Chronicle bit is set

**As a** transaction signer
**I want** `BSV.Sig.preimage/4` to pick OTDA when the Chronicle bit is set and BIP143 when only the forkid bit is set
**So that** Chronicle and pre-Chronicle sigs coexist without interfering

**Acceptance:**
- `preimage(tx, vin, txout, 0x60)` (CHRONICLE | FORKID) → OTDA path
- `preimage(tx, vin, txout, 0x41)` (ALL | FORKID) → BIP143 path (existing behavior)
- `preimage(tx, vin, txout, 0x21)` (ALL | CHRONICLE) → OTDA path
- Behavior when neither bit is set matches BSV node — verify in `bitcoin-sv/src/script/interpreter.cpp` before implementing.

**Test:** `test/bsv/sig_test.exs` — three tests, one per dispatch arm, asserting the correct preimage shape (OTDA has no prevouts/sequence hashes; BIP143 does).

---

### Task 4 — Gate minimal encoding enforcement on `tx.version > 1`

**As a** consumer of a v2+ transaction
**I want** the library to skip minimal-encoding checks on script numbers
**So that** Chronicle's malleability relaxation applies correctly

**Acceptance:**
- Grep `lib/bsv/script_num.ex` and VM first. If minimal encoding is currently enforced, route the check through `tx.version > 1` (skip when true).
- If no minimal-encoding enforcement exists in the library today, log that finding in a PR comment and skip this task.

**Test:** `test/bsv/script_num_test.exs` — paired tests:
- v1 tx with non-minimal script number → enforcement rejects (if enforced)
- v2 tx with same non-minimal script number → accepts

---

### Task 5 — Gate low-S signature enforcement on `tx.version > 1`

**As a** v2+ transaction verifier
**I want** high-S signatures to verify successfully
**So that** Chronicle's malleability relaxation applies correctly

**Acceptance:**
- `BSV.Sig.verify/5` accepts high-S signatures when `tx.version > 1`.
- `BSV.Sig.verify/5` continues to reject high-S signatures when `tx.version == 1` (if currently enforced).
- `BSV.Sig.sign/5` continues to produce low-S by default (signer side is unchanged; only verify relaxes).

**Test:** `test/bsv/sig_test.exs` — paired tests for high-S verify behavior on v1 vs v2.

---

### Task 6 — Gate NULLFAIL on `tx.version > 1`

**As a** v2+ transaction verifier
**I want** `OP_CHECKSIG` and `OP_CHECKMULTISIG` to accept non-empty signatures that fail validation
**So that** Chronicle's malleability relaxation applies correctly

**Acceptance:**
- Grep VM for NULLFAIL enforcement. If present, gate on `vm.ctx |> elem(0) |> Map.get(:version) > 1`.
- Paired behavior on v1 (strict) vs v2 (relaxed).

**Test:** `test/bsv/vm_test.exs` — paired tests: failing sig returns false cleanly on v2, rejects with NULLFAIL-style error on v1.

---

### Task 7 — Gate NULLDUMMY on `tx.version > 1`

Same pattern as NULLFAIL, for the dummy argument to `OP_CHECKMULTISIG`. Grep first; gate if enforced.

**Test:** paired v1/v2 tests in `test/bsv/vm_test.exs`.

---

### Task 8 — Gate MINIMALIF on `tx.version > 1`

Same pattern. `OP_IF` and `OP_NOTIF` input must be exactly `<<0x00>>` or `<<0x01>>` under MINIMALIF; relaxed for v2+.

**Test:** paired v1/v2 tests covering `OP_IF` with a non-minimal truthy value (e.g., `<<0x02>>`).

---

### Task 9 — Gate clean-stack requirement on `tx.version > 1`

Final stack must have exactly one element under clean-stack; any count > 0 accepts for v2+.

**Test:** paired v1/v2 tests in `test/bsv/vm_test.exs`.

---

### Task 10 — Gate data-only unlock-script requirement on `tx.version > 1`

Unlock scripts restricted to pushdata-only under this rule; v2+ allows any opcodes.

**Test:** paired v1/v2 tests using an unlock script that includes a non-pushdata opcode.

---

### Task 11 — Document 32MB script-number consensus bump

One-line comment in `lib/bsv/script_num.ex` noting the Chronicle consensus limit (32MB) so future readers know the bound when enforcement is added. No code change.

**Test:** n/a (docs).

---

## Execution order

Do Tasks 4-10 first (malleability gating, mechanical). They build familiarity with the codebase and each carries paired tests, so coverage grows as you go.

Do Tasks 1-3 last (SIGHASH/OTDA). Crypto correctness needs fresh focus. Pull test vectors from the BSV node functional test suite before writing the preimage code. Run `/codex review` against the sig.ex diff before commit.

Task 11 can land any time.
