namespace Locker.Backend.Application.Mapping;

public interface IMapper<TSource, TDest>
{
    TDest Map(TSource source);
}
