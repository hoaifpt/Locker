import React from 'react';
import { Info } from 'lucide-react';

export default function PaymentCancel() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-100 p-4 dark:bg-gray-900">
      <div className="rounded-lg bg-white p-8 text-center shadow-lg dark:bg-gray-800">
        <Info className="mx-auto mb-4 size-16 text-blue-500" />
        <h1 className="mb-2 text-3xl font-bold text-gray-800 dark:text-white">Thanh toán đã bị hủy</h1>
        <p className="mb-6 text-gray-600 dark:text-gray-300">
          Bạn đã hủy quá trình thanh toán. Không có giao dịch nào được thực hiện.
        </p>
        <a
          href="/"
          className="inline-flex items-center rounded-md bg-orange-500 px-4 py-2 text-white transition hover:bg-orange-600 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2"
        >
          Tiếp tục mua sắm
        </a>
      </div>
    </div>
  );
}

