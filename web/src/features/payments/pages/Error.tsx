import React from 'react';
import { XCircle } from 'lucide-react';

export default function PaymentError() {
    const handleRetry = () => {
        window.history.back(); // Go back to the previous page to retry
    };

    return (
        <div className="flex min-h-screen flex-col items-center justify-center bg-gray-100 p-4 dark:bg-gray-900">
            <div className="rounded-lg bg-white p-8 text-center shadow-lg dark:bg-gray-800">
                <XCircle className="mx-auto mb-4 size-16 text-red-500" />
                <h1 className="mb-2 text-3xl font-bold text-gray-800 dark:text-white">Thanh toán thất bại!</h1>
                <p className="mb-6 text-gray-600 dark:text-gray-300">
                    Đã xảy ra lỗi trong quá trình xử lý thanh toán của bạn. Vui lòng thử lại hoặc liên hệ hỗ trợ.
                </p>
                <div className="flex justify-center space-x-4">
                    <button
                        onClick={handleRetry}
                        className="inline-flex items-center rounded-md bg-blue-500 px-4 py-2 text-white transition hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                    >
                        Thử lại
                    </button>
                    <a href="/" className="inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-gray-700 shadow-sm transition hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600">
                        Quay về trang chủ
                    </a>
                </div>
            </div>
        </div>
    );
}
