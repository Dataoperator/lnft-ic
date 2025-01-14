import { useState } from "react";
import { useMinting } from "../hooks/useMinting";
import { useAuthStore } from "../../auth/auth.store";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { MatrixText } from "@/components/MatrixText";

interface MintFormData {
  name: string;
  description: string;
  traits: {
    intelligence: number;
    adaptability: number;
    creativity: number;
  };
}

const defaultFormData: MintFormData = {
  name: "",
  description: "",
  traits: {
    intelligence: 50,
    adaptability: 50,
    creativity: 50,
  },
};

export const MintingInterface = () => {
  const { isAuthenticated } = useAuthStore();
  const { mint, isLoading, error } = useMinting();
  const [formData, setFormData] = useState<MintFormData>(defaultFormData);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isAuthenticated) {
      return;
    }

    try {
      await mint({
        name: formData.name,
        description: formData.description,
        traits: formData.traits,
      });

      // Reset form after successful mint
      setFormData(defaultFormData);
    } catch (error) {
      console.error("Minting error:", error);
    }
  };

  return (
    <Card className="bg-cyber-dark/50 border border-cyber-neon/30">
      <CardHeader>
        <CardTitle>
          <MatrixText text="Create New Digital Entity" className="text-xl" />
        </CardTitle>
        <CardDescription className="text-cyber-neon/70">
          Initialize a new consciousness with unique traits
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="name" className="text-cyber-neon">
              Entity Designation
            </Label>
            <Input
              id="name"
              placeholder="Enter entity name..."
              value={formData.name}
              onChange={(e) =>
                setFormData({ ...formData, name: e.target.value })
              }
              className="bg-black/50 border-cyber-neon/30 text-cyber-neon"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description" className="text-cyber-neon">
              Neural Imprint
            </Label>
            <Textarea
              id="description"
              placeholder="Describe the entity's purpose..."
              value={formData.description}
              onChange={(e) =>
                setFormData({ ...formData, description: e.target.value })
              }
              className="bg-black/50 border-cyber-neon/30 text-cyber-neon min-h-[100px]"
            />
          </div>

          <div className="space-y-4">
            <Label className="text-cyber-neon">Core Attributes</Label>
            
            <div className="grid gap-4">
              {Object.entries(formData.traits).map(([trait, value]) => (
                <div key={trait} className="space-y-2">
                  <Label htmlFor={trait} className="text-cyber-neon/70 capitalize">
                    {trait}
                  </Label>
                  <div className="flex items-center gap-4">
                    <Input
                      type="range"
                      id={trait}
                      min="0"
                      max="100"
                      value={value}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          traits: {
                            ...formData.traits,
                            [trait]: parseInt(e.target.value),
                          },
                        })
                      }
                      className="flex-1"
                    />
                    <span className="text-cyber-neon w-12 text-right">
                      {value}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <Button
            type="submit"
            disabled={!isAuthenticated || isLoading}
            className="w-full bg-cyber-neon/20 hover:bg-cyber-neon/30 text-cyber-neon border border-cyber-neon/50"
          >
            {isLoading ? (
              <span className="animate-pulse">Initializing...</span>
            ) : (
              "Initialize Entity"
            )}
          </Button>

          {error && (
            <p className="text-red-500 mt-2 text-sm">
              Error: {error.message}
            </p>
          )}
        </form>
      </CardContent>
    </Card>
  );
};