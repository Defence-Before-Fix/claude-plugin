import { test } from 'node:test';
import assert from 'node:assert/strict';
import { cartTotal } from '../src/cart.ts';

test('a cart adds shipping to its lines', () => {
  assert.equal(cartTotal({ items: [{ sku: 'A1', unitPrice: 10, quantity: 1, discountRate: 0.5 }], shippingFee: 3 }), 8);
});
