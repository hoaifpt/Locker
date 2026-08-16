using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using Locker.Backend.Application.Features.Wallet.Commands.Transfer;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Commands.CreatePayment;

public record CreatePaymentCommand(Guid UserId, Guid BookingId, string Method) : IRequest<PaymentDto?>;

public class CreatePaymentCommandHandler : IRequestHandler<CreatePaymentCommand, PaymentDto?>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IMediator _mediator;
    private readonly PaymentMapper _paymentMapper;

    public CreatePaymentCommandHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IOrderRepository orderRepository,
        IMediator mediator,PaymentMapper paymentMapper) // Inject Mediator
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _orderRepository = orderRepository;
        _mediator = mediator;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> Handle(CreatePaymentCommand request, CancellationToken cancellationToken)
    {
        // 1. Lấy đơn hàng
        var order = await _orderRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (order == null || order.UserId != request.UserId) return null;

        // 2. NẾU DÙNG VÍ -> GỌI LỆNH TRANSFER (Chuyển tiền cho Admin)
        if (request.Method.Equals("wallet", StringComparison.OrdinalIgnoreCase))
        {
            var adminId = Guid.Parse("00000000-0000-0000-0000-000000000000"); // ID Admin của bạn
            
            var transferResult = await _mediator.Send(new TransferCommand(
                SenderId: request.UserId,
                ReceiverId: adminId,
                Amount: order.TotalAmount,
                Note: $"Thanh toán cho đơn {order.Id}"
            ), cancellationToken);

            if (!transferResult) throw new Exception("Thanh toán ví thất bại: Không đủ số dư hoặc lỗi hệ thống.");
        }

        // 3. Tạo Booking (Trạng thái Pending)
        var booking = new Booking
        {
            OrderId = order.Id,
            UserId = order.UserId,
            LockerId = order.LockerId,
            SlotIndex = order.SlotIndex,
            PackageId = order.PackageId,
            MobileNumber = order.MobileNumber,
            Status = BookingStatus.Pending // Chờ xác nhận
        };
        await _bookingRepository.CreateAsync(booking, cancellationToken);

        // 4. Tạo Payment
        var payment = new Payment
        {
            BookingId = request.BookingId,
            UserId = request.UserId,
            Amount = order.TotalAmount,
            Method = request.Method,
            Status = request.Method.Equals("wallet", StringComparison.OrdinalIgnoreCase) 
                     ? PaymentStatus.Completed // Nếu là ví thì hoàn tất luôn
                     : PaymentStatus.Pending   // Nếu là vnpay/momo thì chờ webhook
        };
        await _paymentRepository.CreateAsync(payment, cancellationToken);

        return _paymentMapper.Map(payment);
    }
}
