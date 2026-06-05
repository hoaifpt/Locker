using AspNetCore.Identity.MongoDbCore.Models;
using System;

namespace Locker.Backend.Domain.Entities;

public class Role : MongoIdentityRole<Guid>
{
    public Role() : base()
    {
    }

    public Role(string roleName) : base(roleName)
    {
    }
}
