FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y dotnet8 ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /source

# Copy project files while preserving folder structure
COPY TextSearch/*.csproj TextSearch/
COPY Application/*.csproj Application/

# Restore dependencies (make sure the csproj references are valid)
RUN dotnet restore TextSearch/myapp.csproj

# Now copy all the source files (again, relative to the solution root)
COPY TextSearch/ TextSearch/
COPY Application/ Application/

# Build/publish your application
WORKDIR /source/TextSearch
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish myapp.csproj -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=builder /app/publish .

ENTRYPOINT ["dotnet", "myapp.dll"]
