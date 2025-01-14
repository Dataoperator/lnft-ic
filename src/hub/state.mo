import Types "./types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

module {
    public class State() {
        // Core state
        private var lnfts = HashMap.HashMap<Types.TokenId, Types.LNFT>(0, Text.equal, Text.hash);
        private var events = Buffer.Buffer<Types.Event>(0);
        private var nextTokenId : Nat = 0;

        // Token Management
        public func createToken(owner: Principal, name: Text, description: Text) : Types.Result<Types.TokenId, Types.Error> {
            let tokenId = nextTokenId;
            nextTokenId += 1;

            let lnft : Types.LNFT = {
                id = Int.toText(tokenId);
                owner = owner;
                name = name;
                description = description;
                created = Time.now();
                lastInteraction = Time.now();
                emotionalState = {
                    joy = 50;
                    sadness = 50;
                    anger = 50;
                    fear = 50;
                    trust = 50;
                };
                traits = [];
                skills = [];
                memories = [];
                metadata = [];
            };

            lnfts.put(lnft.id, lnft);
            recordEvent(#Transfer, #TransferData({
                from = Principal.fromText("aaaaa-aa");
                to = owner;
                tokenId = lnft.id;
            }), owner);

            #ok(lnft.id)
        };

        public func getToken(tokenId: Types.TokenId) : ?Types.LNFT {
            lnfts.get(tokenId)
        };

        // Event Management
        public func recordEvent(eventType: Types.EventType, data: Types.EventData, source: Principal) {
            let event : Types.Event = {
                id = Int.toText(events.size());
                timestamp = Time.now();
                eventType = eventType;
                data = data;
                source = source;
            };
            events.add(event);
        };

        public func getEvents(count: Nat) : [Types.Event] {
            let size = events.size();
            let start = if (size > count) { size - count } else { 0 };
            Buffer.toArray(Buffer.subBuffer(events, start, count))
        };

        // State Updates
        public func updateEmotionalState(tokenId: Types.TokenId, newState: Types.EmotionalState) : Types.Result<(), Types.Error> {
            switch (lnfts.get(tokenId)) {
                case (null) { #err(#NotFound) };
                case (?token) {
                    let updatedToken = {
                        token with
                        emotionalState = newState;
                        lastInteraction = Time.now();
                    };
                    lnfts.put(tokenId, updatedToken);
                    recordEvent(#EmotionalChange, #EmotionalData({
                        previous = token.emotionalState;
                        current = newState;
                        trigger = "state_update";
                    }), updatedToken.owner);
                    #ok(())
                };
            }
        };

        // Stable Storage
        public func toStable() : {
            lnfts: [(Types.TokenId, Types.LNFT)];
            events: [Types.Event];
            nextTokenId: Nat;
        } {
            {
                lnfts = Iter.toArray(lnfts.entries());
                events = Buffer.toArray(events);
                nextTokenId = nextTokenId;
            }
        };

        public func loadStable(stable: {
            lnfts: [(Types.TokenId, Types.LNFT)];
            events: [Types.Event];
            nextTokenId: Nat;
        }) {
            lnfts := HashMap.fromIter(stable.lnfts.vals(), 0, Text.equal, Text.hash);
            events := Buffer.fromArray(stable.events);
            nextTokenId := stable.nextTokenId;
        };
    };
};