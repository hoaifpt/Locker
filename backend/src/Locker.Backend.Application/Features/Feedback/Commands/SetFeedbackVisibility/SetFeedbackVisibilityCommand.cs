using Locker.Backend.Application.Interfaces;
using MediatR;

namespace Locker.Backend.Application.Features.Feedback.Commands.SetFeedbackVisibility;

public sealed record SetFeedbackVisibilityCommand(Guid Id, bool IsVisible) : IRequest<bool>;

public sealed class SetFeedbackVisibilityCommandHandler
    : IRequestHandler<SetFeedbackVisibilityCommand, bool>
{
    private readonly IFeedbackRepository _repository;

    public SetFeedbackVisibilityCommandHandler(IFeedbackRepository repository) => _repository = repository;

    public Task<bool> Handle(SetFeedbackVisibilityCommand request, CancellationToken cancellationToken)
        => _repository.SetVisibilityAsync(request.Id, request.IsVisible, cancellationToken);
}
