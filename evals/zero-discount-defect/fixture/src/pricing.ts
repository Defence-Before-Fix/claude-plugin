export interface LineItem {
  sku: string;
  unitPrice: number;
  quantity?: number;
  discountRate?: number;
}

export const DEFAULT_QUANTITY = 1;
export const DEFAULT_DISCOUNT_RATE = 0.1;

export function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

export function lineTotal(item: LineItem): number {
  const quantity = item.quantity || DEFAULT_QUANTITY;
  const discountRate = item.discountRate || DEFAULT_DISCOUNT_RATE;
  return round2(item.unitPrice * quantity * (1 - discountRate));
}
