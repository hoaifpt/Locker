using FirebaseAdmin.Auth;
using Locker.Backend.Application.Interfaces;

namespace Locker.Backend.Infrastructure.Services;

public class FirebaseAuthService : IFirebaseAuthService
{
    public async Task<FirebaseToken> VerifyAsync(string idToken)
    {
        return await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
    }
}