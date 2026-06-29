namespace Locker.Backend.Application.Models;

public class PersonalInfoOverviewDto
{
    public PersonalInfoDataDto Data { get; set; } = new();
    public List<PersonalInfoItemDto> Items { get; set; } = [];
    public List<PersonalInfoActionDto> Actions { get; set; } = [];
}

public class PersonalInfoDataDto
{
    public string FullName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string Birthday { get; set; } = string.Empty;
    public string MembershipTier { get; set; } = "Thành viên Vàng";
    public string AvatarUrl { get; set; } = "https://placehold.co/104x104";
}

public class PersonalInfoItemDto
{
    public string Label { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string Hint { get; set; } = string.Empty;
    public bool IsEditable { get; set; } = true;
}

public class PersonalInfoActionDto
{
    public string Title { get; set; } = string.Empty;
    public string Subtitle { get; set; } = string.Empty;
    public string Route { get; set; } = string.Empty;
}
