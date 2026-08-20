import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

test("canonical model migration preserves the protected taxonomy and append-only overrides", async () => {
  const sql = await readFile(
    new URL("../../../packages/database/migrations/0029_engagement_canonical_model.sql", import.meta.url),
    "utf8",
  );
  assert.match(sql, /is_protected boolean NOT NULL DEFAULT true/);
  assert.match(sql, /prevent_protected_canonical_account_mutation/);
  assert.match(sql, /engagement_canonical_model_override_no_update/);
  assert.match(sql, /engagement_canonical_model_override_no_delete/);
  assert.match(sql, /REVOKE UPDATE,DELETE,TRUNCATE/);
  assert.match(sql, /canonical_account_insert_custom/);
});

test("canonical model routes audit create, change and reset operations", async () => {
  const source = await readFile(new URL("../src/index.ts", import.meta.url), "utf8");
  for (const event of [
    "CANONICAL_MODEL_ACCOUNT_ADDED",
    "CANONICAL_MODEL_ACCOUNT_CHANGED",
    "CANONICAL_MODEL_RESET",
  ]) assert.match(source, new RegExp(event));
  assert.match(source, /PROTECTED_CANONICAL_ACCOUNT/);
  assert.match(source, /IMPERMISSIBLE_REPORT_LINE/);
});
