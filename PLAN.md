# PLAN

Work through tasks in order. Each task is a user-story scenario with at least one corresponding test.

---

## Now

Chronicle malleability relaxation (Tasks 4-10 below). Branch: `chronicle-opcodes`.

---

## Chronicle SIGHASH + malleability (remaining from 2026-04-13 handoff)

Branch: `chronicle-opcodes` (off `update-2026-04`). No Chronicle flag — library unconditionally implements Chronicle semantics. Prior context: `.claude/inbox/done/2026-04-13-chronicle-support.md` and `.claude/inbox/done/2026-04-13-chronicle-sighash-and-malleability.md`.

### Done

- **Tasks 1-3 — SIGHASH_CHRONICLE + OTDA.** `Sig.sighash_chronicle?/1`, `Sig.otda_preimage/4`, and `preimage/4`/`sighash/4` dispatch (Chronicle bit → OTDA, ForkID only → BIP143, neither → OTDA, hash-one for out-of-range/SINGLE). Tested against BSV node vectors in `test/vectors/sighash.chronicle.json`.
- **Task 11 — 32MB script-number note** in `lib/bsv/script_num.ex`.
- **Opcode parity check against `@bsv/sdk` 3.2.1 and bitcoin-sv v1.2.1.** Fixed OP_VERIF/OP_VERNOTIF (compare against the 4-byte LE tx version, not OP_IF aliases), OP_RSHIFTNUM rounding toward zero, OP_LSHIFTNUM 32MB result limit, and nested conditionals inside unexecuted branches. Node vectors in `test/vectors/chronicle.verif.json` and `test/vectors/chronicle.shiftnum.json`, run by `test/bsv/vm_chronicle_vectors_test.exs`.

### Known gaps (not scheduled)

- Numeric operands are decoded without a length limit. Multi-megabyte operands can hit the BEAM bignum limit in arithmetic opcodes. The node bounds them by `MaxScriptNumLength`, and splice operands (OP_SUBSTR/LEFT/RIGHT) by 9 bytes.
- `@bsv/sdk` rejects Chronicle sighash on v1 transactions when no verification flags are given. That is an SDK heuristic (the node gates on block height), so this library does not adopt it.

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

## Execution order

Tasks 4-10 in order. Each carries paired v1/v2 tests. Grep for existing enforcement first. Where the library enforces nothing, note it in the task and move on.
