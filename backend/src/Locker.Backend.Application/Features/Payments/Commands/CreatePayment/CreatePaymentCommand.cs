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
    private readonly PaymentMapper _paymentMapper;

    public CreatePaymentCommandHandler(
        IPaymentRepository paymentRepository,
        IBookingRepository bookingRepository,
        PaymentMapper paymentMapper)
    {
        _paymentRepository = paymentRepository;
        _bookingRepository = bookingRepository;
        _paymentMapper = paymentMapper;
    }

    public async Task<PaymentDto?> Handle(CreatePaymentCommand request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
        if (booking == null || booking.UserId != request.UserId) return null;

        var existing = await _paymentRepository.GetByBookingIdAsync(request.BookingId, cancellationToken);
        if (existing != null) return _paymentMapper.Map(existing);

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            BookingId = request.BookingId,
            UserId = request.UserId,
            Amount = booking.TotalAmount,
            Method = request.Method,
            Status = PaymentStatus.Pending
        };

        booking.PaymentId = payment.Id;

        await _paymentRepository.CreateAsync(payment, cancellationToken);
        await _bookingRepository.UpdateAsync(booking, cancellationToken);

        return _paymentMapper.Map(payment);
    }
}
