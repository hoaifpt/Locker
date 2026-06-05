using Locker.Backend.Application.Interfaces;
using Locker.Backend.Application.Mapping;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Locker.Backend.Application.Services;

public class AdminService
{
    private readonly UserManager<User> _userManager;
    private readonly IBookingRepository _bookingRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly UserMapper _userMapper;
    private readonly BookingMapper _bookingMapper;
    private readonly PaymentMapper _paymentMapper;

    public AdminService(
        UserManager<User> userManager,
        IBookingRepository bookingRepository,
        IPaymentRepository paymentRepository,
        UserMapper userMapper,
        BookingMapper bookingMapper,
        PaymentMapper paymentMapper)
    {
        _userManager = userManager;
        _bookingRepository = bookingRepository;
        _paymentRepository = paymentRepository;
        _userMapper = userMapper;
        _bookingMapper = bookingMapper;
        _paymentMapper = paymentMapper;
    }

    public async Task<List<UserDto>> GetAllUsersAsync(CancellationToken cancellationToken)
    {
        // Identity with MongoDB might require explicit fetching or conversion
        var users = _userManager.Users.ToList();
        var dtos = new List<UserDto>();
        foreach (var user in users)
        {
            var dto = _userMapper.Map(user);
            var roles = await _userManager.GetRolesAsync(user);
            dto.Role = roles.FirstOrDefault() ?? "User";
            dtos.Add(dto);
        }
        return dtos;
    }

    public async Task<bool> UpdateUserRoleAsync(Guid userId, string role, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return false;

        var currentRoles = await _userManager.GetRolesAsync(user);
        await _userManager.RemoveFromRolesAsync(user, currentRoles);
        await _userManager.AddToRoleAsync(user, role);
        return true;
    }

    public async Task<bool> DeactivateUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return false;

        user.IsActive = false;
        await _userManager.UpdateAsync(user);
        return true;
    }

    public async Task<bool> ActivateUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return false;

        user.IsActive = true;
        await _userManager.UpdateAsync(user);
        return true;
    }

    public async Task<List<BookingDto>> GetAllBookingsAsync(BookingStatus? status, CancellationToken cancellationToken)
    {
        var bookings = status.HasValue
            ? await _bookingRepository.GetByStatusAsync(status.Value, cancellationToken)
            : await _bookingRepository.GetAllAsync(cancellationToken);

        return bookings.Select(_bookingMapper.Map).ToList();
    }

    public async Task<List<PaymentDto>> GetAllPaymentsAsync(CancellationToken cancellationToken)
    {
        var payments = await _paymentRepository.GetAllAsync(cancellationToken);
        return payments.Select(_paymentMapper.Map).ToList();
    }
}
