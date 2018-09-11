defmodule Prism.Db.Misc do
    def uuid4(return \\ :string) do
        <<a1::size(48), _::size(4), b1::size(12), _::size(2), c1::size(62)>> = :crypto.strong_rand_bytes(16)
        variant = 2  # Indicates RFC 4122
        version = 4  # UUID version number
        uuid4 = <<a1::size(48), version::size(4), b1::size(12), variant::size(2), c1::size(62)>>
        case return do
            :binary -> uuid4
            :string ->
                <<a::binary-size(4), b::binary-size(2), 
                c::binary-size(2), d::binary-size(2), e::binary-size(6)>> = uuid4
                parts = [{a, 8}, {b, 4}, {c, 4}, {d, 4}, {e, 12}]
                hexlify = Enum.map(parts,fn({bin,size})->
                    :string.right(:erlang.integer_to_list(:binary.decode_unsigned(bin, :big), 16), size, 48)
                end)
                :erlang.list_to_binary(:string.to_lower(:string.join(hexlify, '-')))
        end
    end

    def merge_nested(left, right) do
        nested_resolve = fn(_, left, right)->
            case {is_map(left), is_map(right)} do
                {true, true} -> merge_nested(left, right)
                _ -> right
            end
        end
        Map.merge(left, right, nested_resolve)
    end
end