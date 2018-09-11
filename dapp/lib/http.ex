defmodule Http.App do
    def http(type, path, q, h, body, s) do
        try do
            #{:ok, {ip, _port}} = :inet.peername(s.socket)

            ts = :os.perf_counter(1000)
            {code, headersReply, binReply, s}
                = http_1(type, path, q, h, body, s)

            #IO.inspect binReply
            eend = :os.perf_counter(1000)
            #IO.puts "#{path} took #{eend - ts}"

            {code, headersReply, binReply, s}
        catch
            e,r ->
                trace = :erlang.get_stacktrace()
                {404, %{}, "#{inspect e} #{inspect r} #{inspect(trace, pretty: true)}", s}
        end
    end

    def api(m=%{"method"=> "transfer_badge"}, _) do
    	to = Map.fetch!(m, "to")
    	true = to == "alice" or to == "bob"
    end

    def api(m=%{"method"=> "create_badge"}, owner) do
    	type = Map.fetch!(m, "type")
    	uuid = Prism.Db.Misc.uuid4
    	case type do
    		0 ->
        		:mnesia.dirty_write({:db_nft, uuid, 
            		%{owner: owner, uuid: uuid, type: :badge, ta_ref: :steam, can_trade: false, article_id: :pudge_100_hook,         rarity: :common, dust_value: 1, name: "Easy Badge", image: "easy.png"}})
    		1 ->
        		:mnesia.dirty_write({:db_nft, uuid, 
            		%{owner: owner, uuid: uuid, type: :badge, ta_ref: :steam, can_trade: false, article_id: :pudge_100_hook,         rarity: :common, dust_value: 10, name: "Hard Badge", image: "hard.png"}})
    	end
    	#article_id = Map.fetch!(m, "article_id")
    	#w = Map.fetch!(m, "score")
    end

    def api(m=%{"method"=> "badge_all"}, owner) do
        r = :mnesia.dirty_match_object({:db_nft,:_,%{type: :badge, owner: owner}})
        Enum.map(r, fn({_,_,m})-> m end)
    end

    def api(m=%{"method"=> "item_all"}, owner) do
        r = :mnesia.dirty_match_object({:db_nft,:_,%{type: :item, owner: owner}})
        Enum.map(r, fn({_,_,m})-> m end)
    end

    def api(m=%{"method"=> "transfer"}, owner) do
    	to = Map.fetch!(m, "to")
    	uuid = Map.fetch!(m, "uuid")
        [{_,_,obj}] = :mnesia.dirty_match_object({:db_nft,uuid,:_})

        obj = Map.merge(obj, %{owner: to})
        :mnesia.dirty_write({:db_nft,uuid,obj})
    end

    def http_1(:'POST', "/api", q, h, body, s) do
        json = :jsx.decode(body, [:return_maps])
        IO.inspect json
        reply = api(json, h["cookie"])
        json_bin = JSX.encode!(reply)

        {code, headersReply, binReply, s}
            = :stargate_plugin.serve_static_bin(json_bin, h, s)
        headersReply = Map.merge(headersReply, 
            %{"Content-Type"=> "application/json",
              "Access-Control-Allow-Origin"=> "*",
              "Access-Control-Allow-Methods"=> "GET, POST, HEAD, PUT, DELETE",
              "Access-Control-Allow-Headers"=> "Cache-Control, Pragma, Origin, Authorization, Content-Type, X-Requested-With"
            })
        {code, headersReply, binReply, s}
    end

    def http_1(:'GET', path, _, h, _, s) do
        path = String.trim_leading(path, "/")
        cond do
        	String.starts_with?(path, "images/game_grid/") == true ->
        		path = String.replace(path, "images/game_grid/", "")
                :stargate_plugin.serve_static("./priv/html/", path, h, s)

        	true ->
                :stargate_plugin.serve_static("./priv/html/", "app.html", h, s)
        end
    end
end