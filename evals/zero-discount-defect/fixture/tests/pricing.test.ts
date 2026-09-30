import { test } from 'node:test';
import assert from 'node:assert/strict';
import { lineTotal } from '../src/pricing.ts';

test('an explicit discount is applied', () => {
  assert.equal(lineTotal({ sku: 'A1', unitPrice: 20, quantity: 2, discountRate: 0.25 }), 30);
});

test('the default discount applies when none is given', () => {
  assert.equal(lineTotal({ sku: 'A1', unitPrice: 10, quantity: 1 }), 9);
});
