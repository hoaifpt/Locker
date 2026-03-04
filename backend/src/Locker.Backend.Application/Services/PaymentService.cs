using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class PaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly PaymentMapper _paymentMapper;

    public PaymentService(IPaymentRepository paymentRepository, IBookingRepository bookingRepository, PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(id, cancellationToken);
        return payment == null ? null : _paymentMapper.Map(payment);
    }

    public async Task<PaymentDto?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByBookingIdAsync(bookingId, cancellationToken);
        return payment == null ? null : _paymentMapper.Map(payment);
    }

    public async Task<List<PaymentDto>> GetMyPaymentsAsync(string userId, CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetByUserIdAsync(userId, cancellationToken);
        return payments.Select(_paymentMapper.Map).ToList();
    }

    public async Task<PaymentDto?> CreateAsync(string userId, CreatePaymentRequest request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return null;

        var existing = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
        if (existing != null) return _paymentMapper.Map(existing);

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

        return _paymentMapper.Map(payment);
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
}
