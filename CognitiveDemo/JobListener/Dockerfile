FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["JobListener.csproj", "."]
RUN dotnet restore "./JobListener.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "JobListener.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "JobListener.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "JobListener.dll"]