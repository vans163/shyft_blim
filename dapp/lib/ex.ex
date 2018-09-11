defmodule App do
    use Application

    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        IO.puts "Starting App app.."

        #IO.puts "Making directories.."
        #:ok = File.mkdir_p("priv/log/job/")

        IO.puts "Creating mnesia tables.."
        :mnesia.create_schema([:erlang.node])
        :application.ensure_all_started(:mnesia)
        Prism.Db.Nft.create_table
        :mnesia.wait_for_tables(:mnesia.system_info(:local_tables), :infinity)


        IO.puts "Starting webserver.."
        {:ok, _} = :application.ensure_all_started(:stargate)
        webserver_redirect = %{
            ip: {0,0,0,0},
            port: 8000,
            hosts: %{
                {:http, "*"}=> {Http.App, %{}},
                {:ws, "*"}=> {:stargate_handler_redirect_https, %{}}
            }
        }
        #webserver = %{
        #    ip: {0,0,0,0},
        #    port: 443,
        #    ssl_opts: [
        #        {:certfile, "./priv/letsencrypt/domain.crt"},
        #        {:keyfile, "./priv/letsencrypt/domain.key"},
        #        {:cacertfile, "./priv/letsencrypt/lets-encrypt-x3-cross-signed.pem"}
        #    ],
        #    hosts: %{
        #        {:http, "*"}=> {Prism.Web.Http, %{}}
        #    }
        #}
        {:ok, _Pid} = :stargate.warp_in(webserver_redirect)
        #{:ok, _Pid} = :stargate.warp_in(webserver)


        children = [
            #worker(Prism.Job.SupGen, []),
        ]
        opts = [strategy: :one_for_one,
            name: Prism.Supervisor,
            max_seconds: 1,
            max_restarts: 999999999999]
        Supervisor.start_link(children, opts)
    end
end
