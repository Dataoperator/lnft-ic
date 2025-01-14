export const idlFactory = ({ IDL }) => {
  const MetadataValue = IDL.Rec();
  const TokenId = IDL.Nat;
  const EmotionalState = IDL.Record({
    'joy' : IDL.Nat,
    'trust' : IDL.Nat,
    'anger' : IDL.Nat,
    'fear' : IDL.Nat,
    'sadness' : IDL.Nat,
  });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const EmotionalState__1 = IDL.Record({
    'joy' : IDL.Nat,
    'trust' : IDL.Nat,
    'anger' : IDL.Nat,
    'fear' : IDL.Nat,
    'sadness' : IDL.Nat,
  });
  const Time = IDL.Int;
  const Memory = IDL.Record({
    'emotionalImpact' : EmotionalState__1,
    'content' : IDL.Text,
    'timestamp' : Time,
  });
  const Trait = IDL.Record({
    'value' : IDL.Nat,
    'name' : IDL.Text,
    'rarity' : IDL.Nat,
  });
  const TokenId__1 = IDL.Nat;
  const Timestamp = IDL.Int;
  const ApprovalArgs = IDL.Record({
    'token_id' : TokenId__1,
    'from_subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'expires_at' : IDL.Opt(Timestamp),
    'spender' : IDL.Principal,
  });
  const ApprovalError = IDL.Variant({
    'InvalidTokenId' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRequest' : IDL.Null,
  });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Null, 'err' : ApprovalError });
  MetadataValue.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Nat' : IDL.Nat,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'Array' : IDL.Vec(MetadataValue),
    })
  );
  const MetadataContainer__1 = IDL.Variant({
    'Metadata' : IDL.Vec(IDL.Tuple(IDL.Text, MetadataValue)),
    'Blob' : IDL.Vec(IDL.Nat8),
  });
  const Account__1 = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const MetadataContainer = IDL.Variant({
    'Metadata' : IDL.Vec(IDL.Tuple(IDL.Text, MetadataValue)),
    'Blob' : IDL.Vec(IDL.Nat8),
  });
  const MintArgs = IDL.Record({
    'to' : Account__1,
    'metadata' : IDL.Opt(MetadataContainer),
  });
  const Error = IDL.Variant({
    'GenericError' : IDL.Null,
    'InvalidTokenId' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRequest' : IDL.Null,
    'AlreadyExistTokenId' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : TokenId, 'err' : Error });
  const Memo = IDL.Vec(IDL.Nat8);
  const TransferArgs = IDL.Record({
    'to' : Account__1,
    'token_id' : TokenId__1,
    'memo' : IDL.Opt(Memo),
  });
  const TransferError = IDL.Variant({
    'InvalidTokenId' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'InvalidRequest' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : TransferError });
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const LNFT = IDL.Service({
    'addMemory' : IDL.Func([TokenId, IDL.Text, EmotionalState], [Result_3], []),
    'getEmotionalState' : IDL.Func(
        [TokenId],
        [IDL.Opt(EmotionalState)],
        ['query'],
      ),
    'getMemories' : IDL.Func([TokenId], [IDL.Vec(Memory)], ['query']),
    'getTraits' : IDL.Func([TokenId], [IDL.Opt(IDL.Vec(Trait))], ['query']),
    'icrc7_approve' : IDL.Func([ApprovalArgs], [Result_2], []),
    'icrc7_description' : IDL.Func([], [IDL.Text], ['query']),
    'icrc7_metadata' : IDL.Func([], [MetadataContainer__1], ['query']),
    'icrc7_mint' : IDL.Func([MintArgs], [Result], []),
    'icrc7_name' : IDL.Func([], [IDL.Text], ['query']),
    'icrc7_royalties' : IDL.Func([], [IDL.Nat], ['query']),
    'icrc7_royalty_recipient' : IDL.Func([], [IDL.Principal], ['query']),
    'icrc7_supply_cap' : IDL.Func([], [IDL.Opt(IDL.Nat)], ['query']),
    'icrc7_supported_standards' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'icrc7_symbol' : IDL.Func([], [IDL.Text], ['query']),
    'icrc7_total_supply' : IDL.Func([], [IDL.Nat], ['query']),
    'icrc7_transfer' : IDL.Func([TransferArgs], [Result_1], []),
    'mint' : IDL.Func([Account, IDL.Vec(Trait), EmotionalState], [Result], []),
  });
  return LNFT;
};
export const init = ({ IDL }) => { return []; };
