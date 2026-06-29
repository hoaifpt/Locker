// Vị trí: src/Locker.Backend.Domain/Entities/GeoLocation.cs
using System.Collections.Generic;

namespace Locker.Backend.Domain.Entities;

public class GeoLocation
{
    public string Type { get; set; } = "Point";
    public List<double> Coordinates { get; set; } = new List<double>();
}