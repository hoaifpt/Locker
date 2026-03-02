using Locker.Backend.Application.Interfaces;
<<<<<<< HEAD
using Locker.Backend.Application.Mapping;
=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class PaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
<<<<<<< HEAD
    private readonly PaymentMapper _paymentMapper;

    public PaymentService(IPaymentRepository paymentRepository, IBookingRepository bookingRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _paymentMapper = paymentMapper;
=======

    public PaymentService(IPaymentRepository paymentRepository, IBookingRepository bookingRepository)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<PaymentDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(id, cancellationToken);
<<<<<<< HEAD
        return payment == null ? null : _paymentMapper.Map(payment);
=======
        return payment == null ? null : ToDto(payment);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<PaymentDto?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByBookingIdAsync(bookingId, cancellationToken);
<<<<<<< HEAD
        return payment == null ? null : _paymentMapper.Map(payment);
=======
        return payment == null ? null : ToDto(payment);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<List<PaymentDto>> GetMyPaymentsAsync(string userId, CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetByUserIdAsync(userId, cancellationToken);
<<<<<<< HEAD
        return payments.Select(_paymentMapper.Map).ToList();
=======
        return payments.Select(ToDto).ToList();
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<PaymentDto?> CreateAsync(string userId, CreatePaymentRequest request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return null;

        var existing = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
<<<<<<< HEAD
        if (existing != null) return _paymentMapper.Map(existing);
=======
        if (existing != null) return ToDto(existing);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075

        var payment = new Payment
        {
            BookingId = request.BookingId,
            UserId = userId,
            Amount = booking.TotalAmount,
            Method = request.Method,
            Status = PaymentStatus.Pending
        };

        booking.PaymentId = payment.Id;

        await _paymentRepository.CreateAsync(payment, cancellationToken);
        await _bookingRepository.UpdateAsync(booking, cancellationToken);

<<<<<<< HEAD
        return _paymentMapper.Map(payment);
=======
        return ToDto(payment);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<bool> CompleteAsync(string paymentId, string userId, CompletePaymentRequest request, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
        if (payment == null || payment.UserId != userId) return false;
        if (payment.Status != PaymentStatus.Pending) return false;

        payment.Status = PaymentStatus.Completed;
        payment.TransactionId = request.TransactionId;
        payment.PaidAt = DateTime.UtcNow;

        await _paymentRepository.UpdateAsync(payment, cancellationToken);
        return true;
    }
<<<<<<< HEAD
=======

    private static PaymentDto ToDto(Payment p) => new()
    {
        Id = p.Id,
        BookingId = p.BookingId,
        UserId = p.UserId,
        Amount = p.Amount,
        Status = p.Status,
        Method = p.Method,
        TransactionId = p.TransactionId,
        CreatedAt = p.CreatedAt,
        PaidAt = p.PaidAt
    };
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
}
