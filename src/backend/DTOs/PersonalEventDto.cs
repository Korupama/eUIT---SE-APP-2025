using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class PersonalEventRequestDto
{
    [Required(ErrorMessage = "Tên sự kiện không được để trống")]
    [MaxLength(255, ErrorMessage = "Tên sự kiện không được vượt quá 255 ký tự")]
    public string EventName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Thời gian không được để trống")]
    public DateTime Time { get; set; }

    [MaxLength(255, ErrorMessage = "Địa điểm không được vượt quá 255 ký tự")]
    public string? Location { get; set; }

    public string? Description { get; set; }
}

public class PersonalEventUpdateDto
{
    [MaxLength(255, ErrorMessage = "Tên sự kiện không được vượt quá 255 ký tự")]
    public string? EventName { get; set; }

    public DateTime? Time { get; set; }

    [MaxLength(255, ErrorMessage = "Địa điểm không được vượt quá 255 ký tự")]
    public string? Location { get; set; }

    public string? Description { get; set; }
}

public class PersonalEventResponseDto
{
    public int EventId { get; set; }
    public string EventName { get; set; } = string.Empty;
    public DateTime Time { get; set; }
    public string? Location { get; set; }
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class PersonalEventConflictDto
{
    public bool HasConflict { get; set; }
    public string? ConflictType { get; set; } // "class" or "exam"
    public string? ConflictDetails { get; set; }
}

public class PersonalEventCreateResponseDto
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public PersonalEventResponseDto? Event { get; set; }
    public PersonalEventConflictDto? Conflict { get; set; }
}
