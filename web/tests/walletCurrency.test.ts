import assert from 'node:assert/strict';
import test from 'node:test';

import { formatVnd, formatVndInput, normalizeVndInput } from '../src/features/wallet/utils/currency.ts';

test('formats wallet amounts as full Vietnamese dong values', () => {
  assert.equal(formatVnd(50_000), '50.000 ₫');
  assert.equal(formatVnd(2_000_000), '2.000.000 ₫');
});

test('normalizes a formatted Vietnamese dong input for the payment API', () => {
  assert.equal(formatVndInput('100000'), '100.000');
  assert.equal(normalizeVndInput('100.000 ₫'), '100000');
  assert.equal(normalizeVndInput(''), '');
});
