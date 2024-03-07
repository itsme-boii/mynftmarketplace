module Oasis::Oasis{

        use sui::tx_context::TxContext;
        use sui::tx_context ;
        use sui::object::{Self, ID, UID};
        use std::string::String;
        use std::vector;
        use sui::address;
        use sui::transfer;
        use sui::dynamic_object_field as ofield;

        //collection that have ids of the nfts and also the 
        struct Collection has key,store{
            id:UID,
            owner:address,
            name:String,
            arrayOfIds:vector<ID>
        }
        //top level concept
        struct Data has key{
            id:UID
        }

        struct Nft has key,store{
            id:UID,
            image:String,
            name:String,
            description:String,
            traitType:String,
            value:u64,
            owner:address,
            number:u64
        }
  
        struct PublicMint has key,store{
            id:UID,
            mintPrice:u64,
            amountPerWallet:u64,
            royalWallet:address,
            royalities:u64
        }

        struct Presale has key, store{
            id:UID,
            mintPrice:u64,
            amountPerWallet:u64,
            whitelistedAddress:vector<address>
        }

    // this is to make a top parent
        fun init(ctx: &mut TxContext){
            let data=Data{
                id:object::new(ctx)
            };
            transfer::share_object(data);
        }

    // create nftdata parent and then transfer it to the user.
        entry public fun createCollection(data:&mut Data,name:String,ctx:&mut TxContext){
            let sender_address = tx_context::sender(ctx);
            let id=object::new(ctx);
            let collection = Collection{
                id:id,
                owner:sender_address,
                name:name,
                arrayOfIds:vector::empty<ID>(),
            };
            ofield::add(&mut data.id,name,collection)
        }

    // // nft data create and added to pool  
        entry public fun nftData(
            imageUrl:String,
            name:String,
            description:String,
            traitType:String,
            value:u64,
            number:u64,
            collectionName:String,
            data:&mut Data,
            ctx:&mut TxContext)
            {
            let senderaddress = tx_context::sender(ctx);
            let id = object::new(ctx);
            let nft = Nft{
                id:id,
                image:imageUrl,
                name:name,
                description:description,
                traitType:traitType,
                value:value,
                number:number,
                owner:tx_context::sender(ctx)
               
            };
           
            nftData2Tansfer(imageUrl,name,description,traitType,value,number,collectionName,senderaddress,ctx);
             let id=object::id(&nft);
            addToCollection(data,collectionName,id);

            ofield::add(&mut data.id,name,nft);
        }


        entry public fun nftData2Tansfer(
            imageUrl:String,
            name:String,
            description:String,
            traitType:String,
            value:u64,
            number:u64,
            collectionName:String,
            senderAddress:address,
            ctx:&mut TxContext
            )
            {
            let senderaddress = senderAddress;
            let id=object::new(ctx);
        
            let nft = Nft{
                id:id,
                image:imageUrl,
                name:name,
                description:description,
                traitType:traitType,
                value:value,
                number:number,
                owner:senderaddress
               
            };
            transfer::transfer(nft,senderaddress);
        }


        entry public fun addToCollection(
            data: &mut Data,
            collectionName: String,
            id: ID,
        ){
            let coll = ofield::borrow_mut<String, Collection>(&mut data.id, collectionName);
            let array = coll.arrayOfIds;
            vector::push_back(&mut array, id);
            coll.arrayOfIds = array; 
        }


        // entry public fun uid2id(
        //     nft: &mut Nft
        // ):ID{
        //         let id = object::id(nft);
        //         id
        //     }

    // // this will add the nft to user who minted
        // entry public fun mint(
        //     username:String,
        //     nftname:String,
        //     data:&mut Data
        // ){
        //     let nftData = ofield::borrow_mut<String,Nft>(&mut data.id,username);
        //     ofield::add(&mut nftData.id,nftname,nft);
        // }

    
    // // call this function when public mint is active in frontend
    //     entry public fun publicMint(
    //         mintPrice:u64,
    //         amountPerWalet:u64,
    //         royalWallet:address,
    //         royalities:u64,
    //         nft:&mut Nft,
    //         ctx:&mut TxContext
    //     ){
    //         let publicMint = PublicMint{
    //             id:object::new(ctx),
    //             mintPrice:mintPrice,
    //             amountPerWallet:amountPerWalet,
    //             royalWallet:royalWallet,
    //             royalities:royalities
    //         };
    //         ofield::add(&mut nft.id,b"publicMint",publicMint);
    //     }

    // // call this function when presale is set to true in frontend
    //     entry public fun preSale(
    //         mintPrice:u64,
    //         amountPerWalet:u64,
    //         whitelistedAddress:vector<address>,
    //         nft:&mut Nft,
    //         ctx:&mut TxContext
    //     ){
    //         let preSale = Presale{
    //             id:object::new(ctx),
    //             mintPrice:mintPrice,
    //             amountPerWallet:amountPerWalet,
    //             whitelistedAddress:whitelistedAddress
    //         };
    //         ofield::add(&mut nft.id,b"PreSale",preSale);
    //     }

    // //used to push the nft to vector
    //     entry public fun make_vector(data:&mut Data,nft:Nft,uname:String){
    //         let ref=ofield::borrow_mut<String, Vector>(&mut data.id, uname);
    //         vector::push_back(&mut ref.store,nft)
    //     }

}