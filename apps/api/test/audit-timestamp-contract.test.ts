import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const auditInsert = /insert into audit_event\(([^)]*)\)/gi;

test("audit writers preserve the database recording timestamp", async () => {
  for (const path of ["../src/index.ts", "../src/commercial.ts", "../src/permanent-file.ts"]) {
    const source = await readFile(new URL(path, import.meta.url), "utf8");
    const columns = [...source.matchAll(auditInsert)].map((match) => match[1]);
    assert.ok(columns.length > 0, `${path} should contain an audit writer`);
    for (const list of columns) {
      assert.doesNotMatch(
        list!,
        /recorded_at_utc/,
        `${path} must allow the database clock to record ingestion time`,
      );
    }
  }
});

test("audit history exposes occurrence and recording timestamps", async () => {
  const source = await readFile(new URL("../src/index.ts", import.meta.url), "utf8");
  assert.match(
    source,
    /select event_id,occurred_at_utc,recorded_at_utc,actor_id,event_type/,
  );
});
