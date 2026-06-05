using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;
using MediatR;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Features.Admin.Queries.GetAllBookings;

public record GetAllBookingsQuery(BookingStatus? Status) : IRequest<List<BookingDto>>;

public class GetAllBookingsQueryHandler : IRequestHandler<GetAllBookingsQuery, List<BookingDto>>
{
    private readonly IBookingRepository _bookingRepository;
    private readonly BookingMapper _bookingMapper;

    public GetAllBookingsQueryHandler(IBookingRepository bookingRepository, BookingMapper bookingMapper)
    {
        _bookingRepository = bookingRepository;
        _bookingMapper = bookingMapper;
    }

    public async Task<List<BookingDto>> Handle(GetAllBookingsQuery request, CancellationToken cancellationToken)
    {
        var bookings = request.Status.HasValue
            ? await _bookingRepository.GetByStatusAsync(request.Status.Value, cancellationToken)
            : await _bookingRepository.GetAllAsync(cancellationToken);

        return bookings.Select(_bookingMapper.Map).ToList();
    }
}
