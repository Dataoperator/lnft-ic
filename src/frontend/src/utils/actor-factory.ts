import { Actor, ActorSubclass, HttpAgent, Identity } from "@dfinity/agent";
import { Principal } from "@dfinity/principal";
import { IDL } from "@dfinity/candid";

interface CreateActorConfig {
  canisterId: string;
  idlFactory: IDL.InterfaceFactory;
  identity?: Identity;
}

class ActorFactory {
  private static instance: ActorFactory;
  private host: string;
  private agent: HttpAgent | null = null;

  private constructor() {
    this.host = process.env.VITE_DFX_NETWORK === "ic" 
      ? "https://ic0.app" 
      : process.env.VITE_IC_HOST || "http://127.0.0.1:8001";
  }

  public static getInstance(): ActorFactory {
    if (!ActorFactory.instance) {
      ActorFactory.instance = new ActorFactory();
    }
    return ActorFactory.instance;
  }

  private async getAgent(identity?: Identity): Promise<HttpAgent> {
    if (!this.agent || identity) {
      this.agent = new HttpAgent({
        host: this.host,
        identity,
      });

      if (process.env.VITE_DFX_NETWORK !== "ic") {
        await this.agent.fetchRootKey();
      }
    }
    return this.agent;
  }

  public async createActor<T>({
    canisterId,
    idlFactory,
    identity,
  }: CreateActorConfig): Promise<ActorSubclass<T>> {
    const agent = await this.getAgent(identity);
    
    return Actor.createActor<T>(idlFactory, {
      agent,
      canisterId: typeof canisterId === 'string' ? canisterId : canisterId.toString(),
    });
  }
}

export const actorFactory = ActorFactory.getInstance();