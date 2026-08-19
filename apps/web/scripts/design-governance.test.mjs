import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const webRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const repositoryRoot = path.resolve(webRoot, "../..");

test("repository instructions require the authoritative Fluent UI standard", async () => {
  const instructions = await readFile(path.join(repositoryRoot, "AGENTS.md"), "utf8");
  assert.match(instructions, /docs\/FLUENT_UI_STANDARD\.md/);
  assert.match(instructions, /mandatory/i);
});

test("the Fluent UI standard contains enforceable implementation and release policy", async () => {
  const standard = await readFile(
    path.join(repositoryRoot, "docs", "FLUENT_UI_STANDARD.md"),
    "utf8",
  );
  for (const requirement of [
    "@fluentui/react-components",
    "4 px base grid",
    "one primary action",
    "DialogSurface",
    "MessageBar",
    "Windows forced-colors",
    "Statutory output exception",
    "Visual QA matrix",
    "Release gates",
  ])
    assert.ok(standard.includes(requirement), `Missing policy: ${requirement}`);

  assert.match(standard, /https:\/\/fluent2\.microsoft\.design\/design-tokens/);
  assert.match(standard, /private `\.fui-\*` selectors/);
});
