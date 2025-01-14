import React, { useState } from 'react';
import { useMinting } from '../hooks/useMinting';
import { useAuth } from '../hooks/useAuth';
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Slider } from '@/components/ui/slider';
import { toast } from '@/components/ui/use-toast';
import { GridPattern } from './GridPattern';
import { NeuralLink } from './NeuralLink';

interface Trait {
  name: string;
  value: number;
}

type ArchetypeValue = 'sage' | 'warrior' | 'creator' | 'explorer' | '';

export const MintingInterface: React.FC = () => {
  const { isAuthenticated } = useAuth();
  const { mintEntity, isMinting } = useMinting();
  
  const [traits, setTraits] = useState<Trait[]>([
    { name: 'Intelligence', value: 50 },
    { name: 'Empathy', value: 50 },
    { name: 'Creativity', value: 50 },
    { name: 'Resilience', value: 50 }
  ]);
  
  const [archetype, setArchetype] = useState<ArchetypeValue>('');

  const handleTraitChange = (traitName: string, newValue: number) => {
    setTraits(prev => 
      prev.map(trait => 
        trait.name === traitName ? { ...trait, value: newValue } : trait
      )
    );
  };

  const handleMint = async () => {
    if (!isAuthenticated) {
      toast({
        title: "Authentication Required",
        description: "Please connect your Internet Identity to mint an entity.",
        variant: "destructive"
      });
      return;
    }

    try {
      await mintEntity({
        traits,
        archetype,
        timestamp: Date.now()
      });
      
      toast({
        title: "Success",
        description: "Your Living NFT has been minted successfully!",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to mint Living NFT. Please try again.",
        variant: "destructive"
      });
    }
  };

  return (
    <Card className="w-full max-w-2xl mx-auto relative overflow-hidden bg-black/90 text-white border-cyan-500">
      <GridPattern className="absolute inset-0 opacity-10" />
      <NeuralLink className="absolute -top-20 -right-20 opacity-20" />
      
      <CardHeader>
        <CardTitle className="text-3xl font-cyberpunk text-cyan-400">Mint Your Living NFT</CardTitle>
        <CardDescription className="text-cyan-300/70">
          Create a unique digital entity with custom traits and personalities
        </CardDescription>
      </CardHeader>

      <CardContent>
        <div className="space-y-6">
          <div className="space-y-4">
            <label className="text-sm font-medium text-cyan-300">Archetype</label>
            <Select 
              value={archetype} 
              onValueChange={(value: ArchetypeValue) => setArchetype(value)}
            >
              <SelectTrigger className="border-cyan-500 bg-black/50">
                <SelectValue placeholder="Select an archetype" />
              </SelectTrigger>
              <SelectContent className="bg-black border-cyan-500">
                <SelectItem value="sage" className="text-cyan-300">Sage</SelectItem>
                <SelectItem value="warrior" className="text-cyan-300">Warrior</SelectItem>
                <SelectItem value="creator" className="text-cyan-300">Creator</SelectItem>
                <SelectItem value="explorer" className="text-cyan-300">Explorer</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {traits.map(trait => (
            <div key={trait.name} className="space-y-2">
              <div className="flex justify-between">
                <label className="text-sm font-medium text-cyan-300">{trait.name}</label>
                <span className="text-sm text-cyan-400">{trait.value}</span>
              </div>
              <Slider
                value={[trait.value]}
                min={0}
                max={100}
                step={1}
                onValueChange={([value]: number[]) => handleTraitChange(trait.name, value)}
                className="[&>span]:bg-cyan-500"
              />
            </div>
          ))}

          <Button 
            onClick={handleMint} 
            className="w-full bg-cyan-500 hover:bg-cyan-600 text-black font-bold"
            disabled={!isAuthenticated || isMinting || !archetype}
          >
            {isMinting ? "Minting..." : "Mint Entity"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
};