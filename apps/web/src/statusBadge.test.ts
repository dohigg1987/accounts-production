import { describe, expect, it } from "vitest";
import { statusBadgeProps } from "./statusBadge";

describe("statusBadgeProps", () => {
  it.each([
    ["ACTIVE", { appearance: "tint", color: "success" }],
    ["FAILED", { appearance: "tint", color: "danger" }],
    ["Restricted", { appearance: "tint", color: "warning" }],
    ["Not configured", { appearance: "tint", color: "informative" }],
    ["PREPARATION", { appearance: "outline", color: "subtle" }],
  ] as const)("maps %s to its approved semantic treatment", (status, expected) => {
    expect(statusBadgeProps(status)).toEqual(expected);
  });

  it("uses a caution treatment for an unmapped status", () => {
    expect(statusBadgeProps("AWAITING_EXTERNAL_REVIEW")).toEqual({
      appearance: "tint",
      color: "warning",
    });
  });

  it.each([
    ["VOIDED", "danger"],
    ["WITHDRAWN", "danger"],
    ["SUPERSEDED", "subtle"],
    ["INVALIDATED", "danger"],
    ["BLOCKED", "danger"],
    ["REOPENED", "warning"],
    ["NOT_STARTED", "subtle"],
    ["PREPARED", "informative"],
    ["RESPONDED", "informative"],
    ["EXPIRED", "danger"],
    ["PROHIBITED", "danger"],
    ["NOT_APPLICABLE", "subtle"],
  ] as const)("does not render the real %s state as an unknown benign badge", (status, color) => {
    expect(statusBadgeProps(status)).toEqual({
      appearance: color === "subtle" ? "outline" : "tint",
      color,
    });
  });

  it("normalises whitespace and hyphens before mapping", () => {
    expect(statusBadgeProps(" reauth-required ")).toEqual({
      appearance: "tint",
      color: "warning",
    });
  });
});
