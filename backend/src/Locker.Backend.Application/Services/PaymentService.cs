using AutoMapper;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class PaymentService
{
    private readonly IPaymentRepository _paymentRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IMapper _mapper;

    public PaymentService(IPaymentRepository paymentRepository, IBookingRepository bookingRepository, IMapper mapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _mapper = mapper;
    }

    public async Task<PaymentDto?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByIdAsync(id, cancellationToken);
        return payment == null ? null : _mapper.Map<PaymentDto>(payment);
    }

    public async Task<PaymentDto?> GetByBookingIdAsync(string bookingId, CancellationToken cancellationToken)
    {
        var payment = await _paymentRepository.GetByBookingIdAsync(bookingId, cancellationToken);
        return payment == null ? null : _mapper.Map<PaymentDto>(payment);
    }

    public async Task<List<PaymentDto>> GetMyPaymentsAsync(string userId, CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetByUserIdAsync(userId, cancellationToken);
        return _mapper.Map<List<PaymentDto>>(payments);
    }

    public async Task<PaymentDto?> CreateAsync(string userId, CreatePaymentRequest request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != userId) return null;

        var existing = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
        if (existing != null) return _mapper.Map<PaymentDto>(existing);

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

        return _mapper.Map<PaymentDto>(payment);
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
