using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Payments.Commands.CreatePayment;

public record CreatePaymentCommand(Guid UserId, Guid BookingId, string Method) : IRequest<PaymentDto?>;

public class CreatePaymentCommandHandler : IRequestHandler<CreatePaymentCommand, PaymentDto?>
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IOrderRepository _orderRepository; // CẦN THÊM CÁI NÀY
    private readonly IUnitOfWork _unitOfWork;           // CẦN THÊM CÁI NÀY
    private readonly PaymentMapper _paymentMapper;

    public CreatePaymentCommandHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        IOrderRepository orderRepository, // Inject vào
        IUnitOfWork unitOfWork,           // Inject vào
        PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _orderRepository = orderRepository;
        _unitOfWork = unitOfWork;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> Handle(CreatePaymentCommand request, CancellationToken cancellationToken)
    {
        // 1. Lấy đơn hàng (Lưu ý: request.BookingId trong trường hợp này thực tế là OrderId của bạn)
        var order = await _orderRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (order == null || order.UserId != request.UserId) return null;

        // 2. Tạo Booking
        var booking = new Booking
        {
            OrderId = order.Id,
            UserId = order.UserId,
            LockerId = order.LockerId,
            SlotIndex = order.SlotIndex,
            PackageId = order.PackageId,
            MobileNumber = order.MobileNumber,
            Status = BookingStatus.Pending
        };
        await _bookingRepository.AddAsync(booking, cancellationToken);

        // 3. Tạo Payment
        var payment = new Payment
        {
            BookingId = booking.Id,
            OrderId = order.Id,
            UserId = request.UserId,
            Amount = order.TotalAmount,
            Method = request.Method,
            Status = PaymentStatus.Pending
        };
        await _paymentRepository.AddAsync(payment, cancellationToken);

        // 4. Lưu vào Database
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return _paymentMapper.Map(payment);
    }
}
