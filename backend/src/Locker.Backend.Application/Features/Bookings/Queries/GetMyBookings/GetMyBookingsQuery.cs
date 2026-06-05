using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Bookings.Queries.GetMyBookings;

public record GetMyBookingsQuery(Guid UserId, BookingStatus? Status) : IRequest<List<BookingDto>>;

public class GetMyBookingsQueryHandler : IRequestHandler<GetMyBookingsQuery, List<BookingDto>>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly BookingMapper _bookingMapper;

    public GetMyBookingsQueryHandler(IBookingRepository bookingRepository, BookingMapper bookingMapper)
    {
        _bookingRepository = bookingRepository;
        _bookingMapper = bookingMapper;
    }

    public async Task<List<BookingDto>> Handle(GetMyBookingsQuery request, CancellationToken cancellationToken)
    {
        var bookings = await _bookingRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        if (request.Status.HasValue)
            bookings = bookings.Where(b => b.Status == request.Status.Value).ToList();
        return bookings.Select(_bookingMapper.Map).ToList();
    }
}
