using System;
using Xunit; // Hoặc NUnit tùy thuộc dự án test của bạn đang dùng gì

namespace Locker.Backend.Tests;

public class SepayLockerTest
{
    [Fact] // Nếu dự án dùng NUnit thì thay bằng [Test]
    public void Test_Sepay_Split_Invoice_Number()
    {
        // 1. Chuỗi thực tế nhận từ SePay bị đè mã
        string content = "142245799402-0938110861-PAY28336A7F2598C6077";
        
        // 2. Logic xử lý bóc tách lấy phần tử đầu tiên trước dấu '-'
        string[] parts = content.Split('-');
        string cleanInvoiceNumber = parts[0].Trim();
        
        // 3. In kết quả ra màn hình console của Test
        Console.WriteLine($"[TEST OUTPUT] Mã hóa đơn trích xuất: {cleanInvoiceNumber}");
        
        // 4. Kiểm tra xem kết quả có đúng là mã số gốc hệ thống cần hay không
        Assert.Equal("142245799402", cleanInvoiceNumber);
    }
}
