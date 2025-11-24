namespace eUIT.API.DTOs;

public class TrainingScoreDto
{
    public string HocKy { get; set; } = string.Empty;
    public int TongDiem { get; set; }
    public string XepLoai { get; set; } = string.Empty;
    public string TinhTrang { get; set; } = string.Empty;
}

public class TrainingScoreListResponseDto
{
    public List<TrainingScoreDto> TrainingScores { get; set; } = new();
    public string? Message { get; set; }
}
