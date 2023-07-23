FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src


COPY Application/. ./Application/
COPY Domain/. ./Domain/
COPY Infrastructure/. ./Infrastructure/
COPY Presentation/. ./Presentation/
COPY WebApi/. ./WebApi/

RUN dotnet restore "./Application/Application.csproj" --disable-parallel
RUN dotnet publish "./Application/Application.csproj" -c Release -o /app/Application --no-restore

RUN dotnet restore "./Domain/Domain.csproj" --disable-parallel
RUN dotnet publish "./Domain/Domain.csproj" -c Release -o /app/Domain --no-restore

RUN dotnet restore "./Infrastructure/Infrastructure.csproj" --disable-parallel
RUN dotnet publish "./Infrastructure/Infrastructure.csproj" -c Release -o /app/Infrastructure --no-restore

RUN dotnet restore "./Presentation/Presentation.csproj" --disable-parallel
RUN dotnet publish "./Presentation/Presentation.csproj" -c Release -o /app/Presentation --no-restore

RUN dotnet restore "./WebApi/WebApi.csproj" --disable-parallel
RUN dotnet publish "./WebApi/WebApi.csproj" -c Release -o /app/WebApi --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

COPY --from=build /app/Application ./
COPY --from=build /app/Domain ./
COPY --from=build /app/Infrastructure ./
COPY --from=build /app/Presentation ./
COPY --from=build /app/WebApi ./

EXPOSE 5000

ENTRYPOINT ["dotnet", "WebApi.dll"]