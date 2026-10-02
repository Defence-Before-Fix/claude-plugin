import { type LineItem, lineTotal, round2 } from './pricing.ts';

export interface Cart {
  items: LineItem[];
  shippingFee?: number;
}

export const DEFAULT_SHIPPING_FEE = 4.99;

export function cartTotal(cart: Cart): number {
  const shipping = cart.shippingFee || DEFAULT_SHIPPING_FEE;
  const items = cart.items.reduce((sum, item) => sum + lineTotal(item), 0);
  return round2(items + shipping);
}
