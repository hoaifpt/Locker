using FirebaseAdmin.Auth;

namespace Locker.Backend.Application.Interfaces;

public interface IFirebaseAuthService
{
    Task<FirebaseToken> VerifyAsync(string idToken);
}