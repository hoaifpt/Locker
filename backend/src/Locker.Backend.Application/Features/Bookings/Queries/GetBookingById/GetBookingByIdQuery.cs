using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using MediatR;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Queries.GetBookingById;

public record GetBookingByIdQuery(Guid Id) : IRequest<BookingDto?>;

public class GetBookingByIdQueryHandler : IRequestHandler<GetBookingByIdQuery, BookingDto?>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly BookingMapper _bookingMapper;

    public GetBookingByIdQueryHandler(IBookingRepository bookingRepository, BookingMapper bookingMapper)
    {
        _bookingRepository = bookingRepository;
        _bookingMapper = bookingMapper;
    }

    public async Task<BookingDto?> Handle(GetBookingByIdQuery request, CancellationToken cancellationToken)
    {
        var booking = await _bookingRepository.GetByIdAsync(request.Id, cancellationToken);
        return booking == null ? null : _bookingMapper.Map(booking);
    }
}
