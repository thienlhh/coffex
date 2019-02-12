defmodule Coffex.CLI do
  # Default option to show next 4 matches
  @default_cmd "next"
  
  # Default counter items to show
  @default_count 4
  
  # Gets the api token from application configs
  @api_token Application.get_env(:coffex, :api_token)
  
  # Initializes the ExFootball api client struct
  @client ExFootball.Client.new(@api_token)

  # Runs the CLI according to the command line arguments
  def main(argv) do
    argv
    |> parse_args()
    |> process()
  end

  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_processing()
  end

  def args_processing([league, option]) do
    request_data({league_code(league), option})
  end

  def args_processing([league]) do
    request_data({league_code(league), @default_cmd})
  end

  def args_processing(_) do
    :help
  end

  def request_data({code, "next"}) do
    {"matches", [{:id, code}, {:status, "SCHEDULED"}]}
  end

  def request_data({code, "top"}) do
    {"standings", [{:id, code}, {:type, "TOTAL"}]}
  end

  def request_data({code, "top-scorers"}) do
    {"scorers", [{:id, code}]}
  end
  
  def request_data(_) do
    IO.puts("Invalid option")
    IO.puts("---")
    process(:help)
  end

  def process({"matches", params}) do
    ExFootball.Competition.matches!(@client, Keyword.get(params, :id), params)
    |> decode_response("matches")
  end
  
  def process({"standings", params}) do
    ExFootball.Competition.standings!(@client, Keyword.get(params, :id), params)
    |> decode_response("standings")
  end
  
  def process({"scorers", params}) do
    ExFootball.Competition.scorers!(@client, Keyword.get(params, :id), params)
    |> decode_response("scorers")
  end

  def process(:help) do
    IO.puts("""
    usage: coffex [league] [option]

    league:
      premier:                Premier League (England)
      laliga:                 La Liga (Spain)
      serieA:                 Serie A (Itali)
      bundesliga:             Bundesliga 1 (German)

    option:
      next:                   Default option to show next 4 matches
      top:                    Show top 4 teams of current season
      top-scorers:            Show top 4 scorers of current season
    """)

    System.halt()
  end
  
  def league_code(league) do
    case league do
      "premier" -> "PL"
      "laliga" -> "PD"
      "serieA" -> "SA"
      "bundesliga" -> "BL1"
      _ -> "PL"
    end
  end

  def decode_response(%{status: 200, body: body}, sub_resource) do
    case sub_resource do
      "matches" -> print_matches(body[sub_resource])
      "standings" -> print_teams(body[sub_resource])
      "scorers" -> print_scores(body[sub_resource])
    end
  end

  def decode_response(%{status: _, body: body}, _sub_resource) do
    IO.puts("Error: #{body["message"]}")
    System.halt(2)
  end

  def print_matches(matches) do
    headers = [
      {"Start Date (UTC)", :date},
      {"Round", :round},
      {"Home", :home},
      {"Guess", :guess}
    ]

    matches
    |> Enum.take(@default_count)
    |> Enum.map(fn m ->
      %{
        date:
          m["utcDate"]
          |> DateTime.from_iso8601()
          |> date_time_to_string(),
        round: m["matchday"],
        home: m["homeTeam"]["name"],
        guess: m["awayTeam"]["name"]
      }
    end)
    |> print_table(headers)
  end

  def date_time_to_string({:ok, %DateTime{} = dt, _}) do
    "#{dt.month}/#{dt.day}/#{dt.year} #{dt.hour}:" <> String.pad_trailing("#{dt.minute}", 2, "0")
  end

  def date_time_to_string({:error, _}), do: "N/A"

  def print_teams([first | _]) do
    headers = [
      {"Positon", :position},
      {"Points", :points},
      {"Team", :team},
      {"Games", :games}
    ]

    first["table"]
    |> Enum.take(@default_count)
    |> Enum.map(fn t ->
      %{
        position: t["position"],
        points: t["points"],
        team: t["team"]["name"],
        games: t["playedGames"]
      }
    end)
    |> print_table(headers)
  end

  def print_scores(scores) do
    headers = [
      {"Name", :name},
      {"Goals", :goals},
      {"Team", :team}
    ]

    scores
    |> Enum.take(@default_count)
    |> Enum.map(fn s ->
      %{
        name: s["player"]["name"],
        goals: s["numberOfGoals"],
        team: s["team"]["name"]
      }
    end)
    |> print_table(headers)
  end

  def print_table(results, headers) do
    Scribe.print(results, data: headers, colorize: false)
  end
end
