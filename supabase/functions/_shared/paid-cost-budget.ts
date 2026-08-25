export type PaidCostBudgetLimits = Readonly<{
  routeDailyBudgetMicrousd: number;
  routeMonthlyBudgetMicrousd: number;
  userDailyBudgetMicrousd: number;
  userMonthlyBudgetMicrousd: number;
}>;

/**
 * Paid plans do not have a separate per-route or per-user cost ceiling.
 *
 * The reservation RPC requires non-null route and user values, so use the
 * global ceilings for those fields. Because every paid request contributes to
 * the same global totals, these duplicate checks cannot reject a paid user
 * before the global safety ceiling itself is reached.
 */
export function paidCostBudgetLimits(
  globalDailyBudgetMicrousd: number,
  globalMonthlyBudgetMicrousd: number,
): PaidCostBudgetLimits {
  return Object.freeze({
    routeDailyBudgetMicrousd: globalDailyBudgetMicrousd,
    routeMonthlyBudgetMicrousd: globalMonthlyBudgetMicrousd,
    userDailyBudgetMicrousd: globalDailyBudgetMicrousd,
    userMonthlyBudgetMicrousd: globalMonthlyBudgetMicrousd,
  });
}
