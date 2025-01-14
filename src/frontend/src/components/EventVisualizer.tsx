import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

interface Event {
  type: 'emotional' | 'memory' | 'skill' | 'social';
  timestamp: number;
  priority: 'immediate' | 'high' | 'normal' | 'low' | 'background';
  impact: {
    emotional?: number;
    neural?: number;
    trait?: number;
    social?: number;
  };
  metadata?: Record<string, any>;
}

interface EventVisualizerProps {
  tokenId: string;
  actor: any; // IC actor
}

const EventVisualizer: React.FC<EventVisualizerProps> = ({ tokenId, actor }) => {
  const [events, setEvents] = useState<Event[]>([]);
  const [activeEvents, setActiveEvents] = useState<Event[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchEvents = async () => {
      try {
        const history = await actor.getEventHistory(
          Date.now() - 3600000, // Last hour
          Date.now()
        );
        setEvents(history);
      } catch (err) {
        setError('Failed to fetch event history');
        console.error(err);
      }
    };

    fetchEvents();
    const interval = setInterval(fetchEvents, 5000); // Update every 5 seconds

    return () => clearInterval(interval);
  }, [actor, tokenId]);

  useEffect(() => {
    // Subscribe to new events using actor
    const subscribeToEvents = async () => {
      try {
        await actor.subscribeToEvents(tokenId, (event: Event) => {
          setActiveEvents(prev => [...prev, event].slice(-5)); // Keep last 5 active events
          setEvents(prev => [...prev, event]);
        });
      } catch (err) {
        setError('Failed to subscribe to events');
        console.error(err);
      }
    };

    subscribeToEvents();
  }, [actor, tokenId]);

  const getPriorityColor = (priority: string): string => {
    switch (priority) {
      case 'immediate': return 'text-red-500';
      case 'high': return 'text-orange-500';
      case 'normal': return 'text-green-500';
      case 'low': return 'text-blue-500';
      case 'background': return 'text-gray-500';
      default: return 'text-gray-500';
    }
  };

  const formatImpact = (impact: Record<string, number>): React.ReactNode => {
    return Object.entries(impact).map(([key, value]) => (
      <Badge key={key} variant="outline" className="mr-2">
        {key}: {(value * 100).toFixed(1)}%
      </Badge>
    ));
  };

  return (
    <div className="space-y-6">
      {error && (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Active Events Card */}
      <Card>
        <CardHeader>
          <CardTitle>Active Events</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {activeEvents.map((event, index) => (
              <div key={index} className="flex items-center justify-between p-2 border rounded">
                <div>
                  <span className={`font-semibold ${getPriorityColor(event.priority)}`}>
                    {event.type.toUpperCase()}
                  </span>
                  <span className="ml-2 text-sm text-gray-500">
                    {new Date(event.timestamp).toLocaleTimeString()}
                  </span>
                </div>
                <div>{formatImpact(event.impact)}</div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Impact Timeline */}
      <Card>
        <CardHeader>
          <CardTitle>Impact Timeline</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={events}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="timestamp" 
                  tickFormatter={(timestamp) => new Date(timestamp).toLocaleTimeString()}
                />
                <YAxis />
                <Tooltip
                  labelFormatter={(timestamp) => new Date(timestamp).toLocaleString()}
                  formatter={(value: number) => [(value * 100).toFixed(1) + '%']}
                />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="impact.emotional" 
                  stroke="#8884d8" 
                  name="Emotional Impact"
                />
                <Line 
                  type="monotone" 
                  dataKey="impact.neural" 
                  stroke="#82ca9d" 
                  name="Neural Impact"
                />
                <Line 
                  type="monotone" 
                  dataKey="impact.trait" 
                  stroke="#ffc658" 
                  name="Trait Impact"
                />
                <Line 
                  type="monotone" 
                  dataKey="impact.social" 
                  stroke="#ff7300" 
                  name="Social Impact"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      {/* Event Distribution */}
      <Card>
        <CardHeader>
          <CardTitle>Event Distribution</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {['emotional', 'memory', 'skill', 'social'].map(type => {
              const count = events.filter(e => e.type === type).length;
              return (
                <div key={type} className="text-center p-4 border rounded">
                  <div className="text-lg font-semibold">{count}</div>
                  <div className="text-sm text-gray-500">{type}</div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default EventVisualizer;