# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj files and restore as distinct layers
COPY ["GenbaLink.Api/GenbaLink.Api.csproj", "GenbaLink.Api/"]
COPY ["GenbaLink.Core/GenbaLink.Core.csproj", "GenbaLink.Core/"]
COPY ["GenbaLink.DB/GenbaLink.DB.csproj", "GenbaLink.DB/"]
COPY ["GenbaLink.Infrastructure/GenbaLink.Infrastructure.csproj", "GenbaLink.Infrastructure/"]
COPY ["GenbaLink.Shared/GenbaLink.Shared.csproj", "GenbaLink.Shared/"]

RUN dotnet restore "GenbaLink.Api/GenbaLink.Api.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/GenbaLink.Api"
RUN dotnet build "GenbaLink.Api.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "GenbaLink.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Expose port 8080 (standard for Cloud Run)
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "GenbaLink.Api.dll"]
