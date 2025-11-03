# HockeyKit
API Layer for interacting with the SHL and related Web APIs.

## Usage

### Basic Usage

```swift
import HockeyKit

// Initialize with default endpoints
let api = HockeyAPI()

// Use the API
let seasons = try await api.season.getSeasons()
let teams = try await api.team.getTeams()
```

### Custom Endpoint Configuration

You can optionally provide custom base URLs when initializing the API. This is useful for testing against development servers or using alternative endpoints:

```swift
import HockeyKit

// Initialize with a custom base URL
let api = HockeyAPI(baseURL: URL(string: "https://my-custom-api.example.com/api"))

// Or configure all endpoints
let api = HockeyAPI(
    baseURL: URL(string: "https://my-custom-api.example.com/api"),
    liveBaseURL: URL(string: "https://my-game-data.example.com"),
    broadcasterBaseURL: URL(string: "https://my-broadcaster.example.com")
)
```

**Parameters:**
- `baseURL`: Base URL for the main SHL API (default: `https://www.shl.se/api`)
- `liveBaseURL`: Base URL for live game data (default: `https://game-data.s8y.se`)
- `broadcasterBaseURL`: Base URL for broadcaster data (default: `https://game-broadcaster.s8y.se`)

All parameters are optional. If not provided, the default SHL endpoints will be used.

