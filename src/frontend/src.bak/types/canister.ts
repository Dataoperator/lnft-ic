import { Actor, ActorSubclass, Agent, Identity } from '@dfinity/agent';

export type InterfaceFactory = {
  createActor: <T>(
    canisterId: string,
    options?: {
      agentOptions?: {
        host?: string;
        identity?: Identity;
      };
      actorOptions?: {
        agent?: Agent;
      };
    }
  ) => ActorSubclass<T>;
};

export const createCanisterActor = <T>(
  factory: InterfaceFactory,
  canisterId: string,
  options?: {
    agentOptions?: {
      host?: string;
      identity?: Identity;
    };
    actorOptions?: {
      agent?: Agent;
    };
  }
): ActorSubclass<T> => {
  return factory.createActor<T>(canisterId, options);
};