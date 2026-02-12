using System;
using System.Collections.Generic;

namespace GenbaLink.Shared.DTOs;

public record DemandBatchDto(
    string StoreId,
    Guid BatchId,
    DateTime Timestamp,
    List<DemandSignalDto> Signals
);

public record DemandSignalDto(
    Guid Id,
    string RawInput,
    ExtractedAttributesDto ExtractedAttributes,
    DateTime CapturedAt
);

public record ExtractedAttributesDto(
    string Category,
    string Color,
    string Size
);
