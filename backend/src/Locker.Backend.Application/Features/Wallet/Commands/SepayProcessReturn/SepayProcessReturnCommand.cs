using Locker.Backend.Application.Interfaces;
using Locker.Backend.Domain.Entities;
using Locker.Backend.Domain.Enums;
using MediatR;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;


namespace Locker.Backend.Application.Features.Wallet.Commands.SepayProcessReturn;

/// <summary>
/// Command để xử lý dữ liệu trả về từ cổng thanh toán Sepay.
/// </summary>
public record SepayProcessReturnCommand(IDictionary<string, string> Parameters) : IRequest<SepayProcessReturnResponse>;

/// <summary>
/// DTO kết quả trả về cho client sau khi xử lý Sepay return.
/// </summary>
public record SepayProcessReturnResponse(bool Success, string Message, string? TransactionId = null);

/// <summary>
/// Handler xử lý logic cho SepayProcessReturnCommand.
/// </summary>
public class SepayProcessReturnCommandHandler : IRequestHandler<SepayProcessReturnCommand, SepayProcessReturnResponse>
{
    private readonly ISepayService _sepayService;
    private readonly IWalletTransactionRepository _walletTransactionRepository;
    private readonly IIdentityService _identityService;

    public SepayProcessReturnCommandHandler(
        ISepayService sepayService,
        IWalletTransactionRepository walletTransactionRepository,
        IIdentityService identityService)
    {
        _sepayService = sepayService;
        _walletTransactionRepository = walletTransactionRepository;
        _identityService = identityService;
    }

    public async Task<SepayProcessReturnResponse> Handle(SepayProcessReturnCommand request, CancellationToken cancellationToken)
    {
        // 1. Xác thực chữ ký từ Sepay để đảm bảo dữ liệu không bị thay đổi
        if (!_sepayService.VerifySepayReturnUrl(request.Parameters, out var errorMessage))
        {
            return new SepayProcessReturnResponse(false, errorMessage);
        }

        // 2. Parse các tham số từ URL thành một đối tượng có cấu trúc
        var paymentResponse = _sepayService.ProcessSepayReturn(request.Parameters);

        // 3. Kiểm tra trạng thái giao dịch từ Sepay
        if (!paymentResponse.IsSuccess)
        {
            return new SepayProcessReturnResponse(false, paymentResponse.Message, paymentResponse.TransactionId);
        }

        // 4. Kiểm tra giao dịch đã được xử lý trước đó chưa (để tránh cộng tiền 2 lần)
        var existingTransaction = await _walletTransactionRepository.FindOneAsync(
            x => x.ReferenceId == paymentResponse.TransactionId && x.Type == TransactionType.TopUp,
            cancellationToken);

        if (existingTransaction != null)
        {
            return new SepayProcessReturnResponse(true, "Giao dịch đã được xử lý thành công trước đó.", existingTransaction.ReferenceId);
        }

        // 5. Tạo và lưu giao dịch nạp tiền mới vào ví
        var walletTransaction = new WalletTransaction
        {
            UserId = paymentResponse.UserId,
            Amount = paymentResponse.Amount,
            Description = $"Nạp tiền qua Sepay. Mã GD Cổng TT: {paymentResponse.GatewayTransactionNo}",
            ReferenceId = paymentResponse.TransactionId, // Mã giao dịch của hệ thống mình
            CreatedAt = paymentResponse.TransactionDate, // Đã được chuyển sang UTC trong SepayService
            Type = TransactionType.TopUp, // Đây là giao dịch nạp tiền
            Status = TransactionStatus.Completed // Giao dịch thành công
        };

        await _walletTransactionRepository.CreateAsync(walletTransaction, cancellationToken);

        // 6. Trả về kết quả thành công
        return new SepayProcessReturnResponse(true, "Nạp tiền thành công!", paymentResponse.TransactionId);
    }
}