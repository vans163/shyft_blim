defmodule Prism.Db.Nft do
    @rec :db_nft

    def populate() do
        #:mnesia.dirty_write({:db_nft, "5abd8d0b-7686-4d48-a259-c4b7efaf67fe", 
        #    %{owner: "bob", uuid: "5abd8d0b-7686-4d48-a259-c4b7efaf67fe", type: :badge, ta_ref: :steam, can_trade: false, article_id: :pudge_100_hook,         rarity: :common, dust_value: 1, name: "100 Pudge Hooks", image: "pudge.png"}})
        #:mnesia.dirty_write({:db_nft, "93e68cef-ebd3-4b96-b54d-e4b2a58a8707", 
        #    %{owner: "alice", uuid: "93e68cef-ebd3-4b96-b54d-e4b2a58a8707", type: :badge, ta_ref: :steam, can_trade: false, article_id: :place_1_2018_dota_int,  rarity: :ultra_rare, dust_value: 10, name: "2018 Dota Champion", image: "dota2_champ.jpeg"}})

        :mnesia.dirty_write({:db_nft, "3af1152d-940e-4db9-aeb6-13aef66443d7", 
            %{owner: "bob", uuid: "3af1152d-940e-4db9-aeb6-13aef66443d7", type: :item, ta_ref: :blizzard, can_trade: true, article_id: :crown_of_ages, name: "Crown of Ages", image: "coa.gif", dust_value: 1}})
        :mnesia.dirty_write({:db_nft, "455944bb-cf0b-438b-a5c1-c96259f12ae6", 
            %{owner: "alice", uuid: "455944bb-cf0b-438b-a5c1-c96259f12ae6", type: :item, ta_ref: :steam, can_trade: true, article_id: :ibovd, name: "Inscribed Blades of Voth Domosh", image: "dota2.png", dust_value: 10}})
        :mnesia.dirty_write({:db_nft, "3824d84f-9d0a-4c89-9df4-425a465a8576", 
            %{owner: "alice", uuid: "3824d84f-9d0a-4c89-9df4-425a465a8576", type: :item, ta_ref: :blizzard, can_trade: true, article_id: :zod, name: "Zod Rune (x4)", image: "zod.png", count: 4, dust_value: 1}})


    end

    def by_uuid(uuid), do: :mnesia.activity(:transaction, fn->
        case :mnesia.read({@rec, uuid}) do
            [{_,uuid,data}] -> data
            _ -> nil
        end
    end)
    def by_email(email), do: :mnesia.activity(:transaction, fn->
        case :mnesia.match_object({@rec, :_, %{email: email}}) do
            [{_,uuid,data}] -> data
            _ -> nil
        end
    end)
    def by_session_token(session_token), do: :mnesia.activity(:transaction, fn->
        session_token = String.replace(session_token, ["\"", "'"], "")
        case :mnesia.match_object({@rec, :_, %{session_token: session_token}}) do
            [{_,uuid,data}] -> data
            _ -> nil
        end
    end)
    def by_key_secret(key,secret), do: :mnesia.activity(:transaction, fn->
        case :mnesia.match_object({@rec, :_, %{api_key: key, api_key_secret: secret}}) do
            [{_,uuid,data}] -> data
            _ -> nil
        end
    end)

    def create(data\\%{}), do: :mnesia.activity(:transaction, fn()->
        uuid = Prism.Db.Misc.uuid4
        data = Map.merge(data, %{uuid: uuid, _tsu: :os.system_time(1000), _tsc: :os.system_time(1000)})
        :ok = :mnesia.write({@rec,uuid,data})
        uuid
    end)
    def merge(uuid, data), do: :mnesia.activity(:transaction, fn()->
        [{@rec, ^uuid, old_data}] = :mnesia.wread({@rec, uuid})
        data = Map.merge(old_data, data)
        data = Map.merge(data, %{_tsu: :os.system_time(1000)})
        :ok = :mnesia.write({@rec, uuid, data})
        data
    end)
    def delete(uuid), do: :mnesia.activity(:transaction, fn()->
        :ok = :mnesia.delete({@rec, uuid})
    end)
    def get(uuid), do: :mnesia.activity(:transaction, fn()->
        [{_,_,data}] = :mnesia.read({@rec,uuid})
        data
    end)

    def create_table do
        :mnesia.create_table(
            @rec, [
                disc_copies: [node()], 
                #type: :ordered_set,
                attributes: [:uuid,:data]
            ])
    end
end