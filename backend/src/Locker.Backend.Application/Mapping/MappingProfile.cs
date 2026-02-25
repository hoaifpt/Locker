using AutoMapper;
using Locker.Backend.Application.Models;
using Locker.Backend.Domain.Entities;
using LockerEntity = Locker.Backend.Domain.Entities.Locker;

namespace Locker.Backend.Application.Mapping;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // User
        CreateMap<User, UserDto>();

        // Locker
        CreateMap<LockerEntity, LockerDto>();
        CreateMap<LockerSlot, LockerSlotDto>();
        CreateMap<CreateLockerRequest, LockerEntity>();
        CreateMap<UpdateLockerRequest, LockerEntity>();

        // Package
        CreateMap<Package, PackageDto>();
        CreateMap<CreatePackageRequest, Package>();
        CreateMap<UpdatePackageRequest, Package>();

        // Booking
        CreateMap<Booking, BookingDto>();

        // Payment
        CreateMap<Payment, PaymentDto>();
    }
}
