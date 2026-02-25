using AutoMapper;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class AdminService
{
    private readonly IUserRepository _userRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IMapper _mapper;

    public AdminService(
        IUserRepository userRepository,
        IBookingRepository bookingRepository,
        IPaymentRepository paymentRepository,
        IMapper mapper)
    {
        _userRepository = userRepository;
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
        _mapper = mapper;
    }

    public async Task<List<UserDto>> GetAllUsersAsync(CancellationToken cancellationToken)
    {
        var users = await _userRepository.GetAllAsync(cancellationToken);
        return _mapper.Map<List<UserDto>>(users);
    }

    public async Task<bool> UpdateUserRoleAsync(string userId, string role, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null) return false;

        user.Role = role;
        await _userRepository.UpdateAsync(user, cancellationToken);
        return true;
    }

    public async Task<bool> DeactivateUserAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null) return false;

        user.IsActive = false;
        await _userRepository.UpdateAsync(user, cancellationToken);
        return true;
    }

    public async Task<bool> ActivateUserAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user == null) return false;

        user.IsActive = true;
        await _userRepository.UpdateAsync(user, cancellationToken);
        return true;
    }

    public async Task<List<BookingDto>> GetAllBookingsAsync(BookingStatus? status, CancellationToken cancellationToken)
    {
        var bookings = status.HasValue
            ? await _bookingRepository.GetByStatusAsync(status.Value, cancellationToken)
            : await _bookingRepository.GetAllAsync(cancellationToken);

        return _mapper.Map<List<BookingDto>>(bookings);
    }

    public async Task<List<PaymentDto>> GetAllPaymentsAsync(CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetAllAsync(cancellationToken);
        return _mapper.Map<List<PaymentDto>>(payments);
    }
}
