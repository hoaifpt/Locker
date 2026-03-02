using Locker.Backend.Application.Interfaces;
<<<<<<< HEAD
using Locker.Backend.Application.Mapping;
=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Application.Services;

public class AdminService
{
    private readonly IUserRepository _userRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPaymentRepository _paymentRepository;
<<<<<<< HEAD
    private readonly UserMapper _userMapper;
    private readonly BookingMapper _bookingMapper;
    private readonly PaymentMapper _paymentMapper;
=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075

    public AdminService(
        IUserRepository userRepository,
        IBookingRepository bookingRepository,
<<<<<<< HEAD
        IPaymentRepository paymentRepository,
        UserMapper userMapper,
        BookingMapper bookingMapper,
        PaymentMapper paymentMapper)
=======
        IPaymentRepository paymentRepository)
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    {
        _userRepository = userRepository;
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
<<<<<<< HEAD
        _userMapper = userMapper;
        _bookingMapper = bookingMapper;
        _paymentMapper = paymentMapper;
=======
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<List<UserDto>> GetAllUsersAsync(CancellationToken cancellationToken)
    {
        var users = await _userRepository.GetAllAsync(cancellationToken);
<<<<<<< HEAD
        return users.Select(_userMapper.Map).ToList();
=======
        return users.Select(u => new UserDto
        {
            Id = u.Id,
            Username = u.Username,
            Email = u.Email,
            FullName = u.FullName,
            Role = u.Role,
            IsActive = u.IsActive,
            CreatedAt = u.CreatedAt
        }).ToList();
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
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

<<<<<<< HEAD
        return bookings.Select(_bookingMapper.Map).ToList();
=======
        return bookings.Select(b => new BookingDto
        {
            Id = b.Id,
            UserId = b.UserId,
            LockerId = b.LockerId,
            SlotIndex = b.SlotIndex,
            PackageId = b.PackageId,
            MobileNumber = b.MobileNumber,
            Status = b.Status,
            TotalAmount = b.TotalAmount,
            PaymentId = b.PaymentId,
            CreatedAt = b.CreatedAt,
            StartedAt = b.StartedAt,
            CompletedAt = b.CompletedAt
        }).ToList();
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }

    public async Task<List<PaymentDto>> GetAllPaymentsAsync(CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetAllAsync(cancellationToken);
<<<<<<< HEAD
        return payments.Select(_paymentMapper.Map).ToList();
=======
        return payments.Select(p => new PaymentDto
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
        }).ToList();
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
    }
}
