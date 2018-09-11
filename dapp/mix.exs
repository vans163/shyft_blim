defmodule App.Mixfile do
    use Mix.Project

    def project, do: [
        app: :app,
        version: "0.0.1",
        elixir: "~> 1.6",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps(),
    ]

    def application, do: [
        applications: [:logger],
        mod: {App, []}
    ]

    def deps, do: [
        {:exjsx, "~> 4.0.0"},
        {:comsat, git: "https://github.com/vans163/ComSat.git"},
        {:stargate, git: "https://github.com/vans163/stargate.git"},
        {:zarex, git: "https://github.com/ricn/zarex"}
    ]
end
