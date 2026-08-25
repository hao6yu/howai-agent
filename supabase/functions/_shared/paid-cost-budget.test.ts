import { assertEquals, assertNotStrictEquals } from "jsr:@std/assert@1.0.19";

import { paidCostBudgetLimits } from "./paid-cost-budget.ts";

Deno.test("paid cost limits are governed only by the global safety ceilings", () => {
  const limits = paidCostBudgetLimits(10_000_000, 150_000_000);

  assertEquals(limits, {
    routeDailyBudgetMicrousd: 10_000_000,
    routeMonthlyBudgetMicrousd: 150_000_000,
    userDailyBudgetMicrousd: 10_000_000,
    userMonthlyBudgetMicrousd: 150_000_000,
  });
});

Deno.test("paid cost limit results are immutable snapshots", () => {
  const first = paidCostBudgetLimits(10_000_000, 150_000_000);
  const second = paidCostBudgetLimits(20_000_000, 300_000_000);

  assertNotStrictEquals(first, second);
  assertEquals(Object.isFrozen(first), true);
  assertEquals(first.routeDailyBudgetMicrousd, 10_000_000);
  assertEquals(second.routeDailyBudgetMicrousd, 20_000_000);
});
