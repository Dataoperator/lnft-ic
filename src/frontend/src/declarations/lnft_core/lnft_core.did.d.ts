import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Uint8Array | number[]],
}
export interface Account__1 {
  'owner' : Principal,
  'subaccount' : [] | [Uint8Array | number[]],
}
export interface ApprovalArgs {
  'token_id' : TokenId__1,
  'from_subaccount' : [] | [Uint8Array | number[]],
  'expires_at' : [] | [Timestamp],
  'spender' : Principal,
}
export type ApprovalError = { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRequest' : null };
export interface EmotionalState {
  'joy' : bigint,
  'trust' : bigint,
  'anger' : bigint,
  'fear' : bigint,
  'sadness' : bigint,
}
export interface EmotionalState__1 {
  'joy' : bigint,
  'trust' : bigint,
  'anger' : bigint,
  'fear' : bigint,
  'sadness' : bigint,
}
export type Error = { 'GenericError' : null } |
  { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRequest' : null } |
  { 'AlreadyExistTokenId' : null };
export interface LNFT {
  'addMemory' : ActorMethod<[TokenId, string, EmotionalState], Result_3>,
  'getEmotionalState' : ActorMethod<[TokenId], [] | [EmotionalState]>,
  'getMemories' : ActorMethod<[TokenId], Array<Memory>>,
  'getTraits' : ActorMethod<[TokenId], [] | [Array<Trait>]>,
  'icrc7_approve' : ActorMethod<[ApprovalArgs], Result_2>,
  'icrc7_description' : ActorMethod<[], string>,
  'icrc7_metadata' : ActorMethod<[], MetadataContainer__1>,
  'icrc7_mint' : ActorMethod<[MintArgs], Result>,
  'icrc7_name' : ActorMethod<[], string>,
  'icrc7_royalties' : ActorMethod<[], bigint>,
  'icrc7_royalty_recipient' : ActorMethod<[], Principal>,
  'icrc7_supply_cap' : ActorMethod<[], [] | [bigint]>,
  'icrc7_supported_standards' : ActorMethod<[], Array<string>>,
  'icrc7_symbol' : ActorMethod<[], string>,
  'icrc7_total_supply' : ActorMethod<[], bigint>,
  'icrc7_transfer' : ActorMethod<[TransferArgs], Result_1>,
  'mint' : ActorMethod<[Account, Array<Trait>, EmotionalState], Result>,
}
export type Memo = Uint8Array | number[];
export interface Memory {
  'emotionalImpact' : EmotionalState__1,
  'content' : string,
  'timestamp' : Time,
}
export type MetadataContainer = {
    'Metadata' : Array<[string, MetadataValue]>
  } |
  { 'Blob' : Uint8Array | number[] };
export type MetadataContainer__1 = {
    'Metadata' : Array<[string, MetadataValue]>
  } |
  { 'Blob' : Uint8Array | number[] };
export type MetadataValue = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<MetadataValue> };
export interface MintArgs {
  'to' : Account__1,
  'metadata' : [] | [MetadataContainer],
}
export type Result = { 'ok' : TokenId } |
  { 'err' : Error };
export type Result_1 = { 'ok' : null } |
  { 'err' : TransferError };
export type Result_2 = { 'ok' : null } |
  { 'err' : ApprovalError };
export type Result_3 = { 'ok' : null } |
  { 'err' : string };
export type Time = bigint;
export type Timestamp = bigint;
export type TokenId = bigint;
export type TokenId__1 = bigint;
export interface Trait { 'value' : bigint, 'name' : string, 'rarity' : bigint }
export interface TransferArgs {
  'to' : Account__1,
  'token_id' : TokenId__1,
  'memo' : [] | [Memo],
}
export type TransferError = { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'InvalidRequest' : null };
export interface _SERVICE extends LNFT {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
