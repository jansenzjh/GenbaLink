using System;
using System.Threading.Tasks;
using GenbaLink.Shared.DTOs;

namespace GenbaLink.Core.Interfaces;

public interface IDemandAggregator
{
    Task ProcessBatchAsync(DemandBatchDto batch);
}
