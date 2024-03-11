    module Oasis::Oasis {
    use std::string::String;
    use std::ascii::{String as Ascii};
    use std::vector;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::url;
    use sui::coin::{Coin};
    use sui::sui::SUI;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};
    use nft_protocol::collection::{Self};
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::listing::{Self, Listing};
    use nft_protocol::display;
    use nft_protocol::royalty;
    use nft_protocol::attributes;
    use nft_protocol::witness::{Self};
    use nft_protocol::limited_fixed_price;

    struct Oasis has store, drop {}
    struct NFTCarrier has key { id: UID, witness: KEEPSAKE }
    struct Witness has drop {}

     fun init(ctx: &mut TxContext) {
        let sender=tx_context::sender(ctx);
        let nftCarrier = NFTCarrier{
            id:object::new(ctx),
            witness:Oasis{}
        };
        transfer::transfer(nftCarrier,sender)
        }

    public entry fun create(
        name: String,
        description: String,
        symbol: String,
        royalty_receiver: address,
        _tags: vector<vector<u8>>,
        royalty_fee_bps: u64,
        _max_supply: u64,
        carrier: NFTCarrier,
        ctx: &mut TxContext,
    ) {
        let NFTCarrier { id, witness } = carrier;
        object::delete(id);

        let (mint_cap, collection) = collection::create<Oasis>(
            & witness,
            ctx,
        );
        let delegated_witness = witness::from_witness<Oasis, Witness>(&Witness {});
        let collectionControlCap = transfer_allowlist::create_collection_cap<KEEPSAKE>(delegated_witness, ctx);
        transfer::public_transfer(collectionControlCap, tx_context::sender(ctx));
        
        display::add_collection_display_domain<Oasis, Oasis>(&Oasis {}, &mut collection, name, description);
        display::add_collection_symbol_domain<Oasis, Oasis>(&Oasis {}, &mut collection, symbol);

        let royalty = royalty::from_address(royalty_receiver, ctx);
        royalty::add_proportional_royalty(
            &mut royalty,
            royalty_fee_bps,
        );
        royalty::add_royalty_domain<Oasis, Oasis>(&Oasis{}, &mut collection, royalty);

        transfer::public_share_object(collection);
        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
    }

}