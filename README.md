# Coffex
Coffex is A football CLI written in Elixir. Provides informations about popular national championships in the world.

# Usage
- Make sure [erlang](http://www.erlang.org/) was installed
- On Windows machines add `escript` before `coffex` command
```
usage: coffex <league> <option>

league:
  premier:                Premier League (England)
  laliga:                 La Liga (Spain)
  serieA:                 Serie A (Itali)
  bundesliga:             Bundesliga 1 (German)

option:
  next:                   Default option to show next 4 matches
  top:                    Show top 4 teams of current season
  top-scorers:            Show top 4 scorers of current season
```

# Development
The steps to run `coffex` in local machines
- Installs Elixir and erlang
- Gets `api token` from [football-data.org](https://www.football-data.org/)
- Clones the repository
```
> git clone https://github.com/thienlhh/coffex.git
```
- Configs your `api token` in the `config.exs` file
```
# Config the football-data.org api token here
config :coffex, api_token: "<your-api-token>"
```
- Runs the application in `iex`
```
> cd coffex
> mix deps.get
> iex -S mix
```
- Builds executable file
```
> mix deps.get
> mix escript.build
```