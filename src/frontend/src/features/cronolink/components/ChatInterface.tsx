import React, { useState, useEffect, useRef } from 'react';
import { useCronolinkStore } from '../cronolink.store';
import { EmotionalState } from '../../../types';

interface ChatInterfaceProps {
  lnftId: string;
}

export const ChatInterface: React.FC<ChatInterfaceProps> = ({ lnftId }) => {
  const { 
    messages,
    currentEmotionalState,
    isLoading,
    error,
    sendMessage,
    fetchEmotionalState,
    fetchMemories 
  } = useCronolinkStore();

  const [input, setInput] = useState('');
  const chatEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    fetchEmotionalState(lnftId);
    fetchMemories(lnftId);
  }, [lnftId]);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    await sendMessage(lnftId, input.trim());
    setInput('');
  };

  const getEmotionColor = (emotion: EmotionalState) => {
    const intensityScale = Math.min(Math.max(emotion.intensity / 100, 0), 1);
    switch (emotion.mood.toLowerCase()) {
      case 'happy':
        return `rgba(255, 193, 7, ${intensityScale})`;
      case 'sad':
        return `rgba(3, 169, 244, ${intensityScale})`;
      case 'angry':
        return `rgba(244, 67, 54, ${intensityScale})`;
      case 'neutral':
        return `rgba(158, 158, 158, ${intensityScale})`;
      default:
        return `rgba(158, 158, 158, ${intensityScale})`;
    }
  };

  return (
    <div className="flex flex-col h-full bg-gray-50 rounded-lg overflow-hidden">
      {/* Emotional State Display */}
      {currentEmotionalState && (
        <div 
          className="p-2 text-sm text-center text-white"
          style={{ backgroundColor: getEmotionColor(currentEmotionalState) }}
        >
          Current Mood: {currentEmotionalState.mood} 
          (Intensity: {currentEmotionalState.intensity}%)
        </div>
      )}

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map(message => (
          <div 
            key={message.id}
            className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[70%] rounded-lg p-3 ${
                message.sender === 'user'
                  ? 'bg-blue-600 text-white'
                  : 'bg-white border border-gray-200'
              }`}
            >
              <p className="text-sm">{message.content}</p>
              {message.emotionalState && (
                <div 
                  className="mt-1 text-xs opacity-75"
                  style={{ color: message.sender === 'user' ? 'white' : 'black' }}
                >
                  Mood: {message.emotionalState.mood}
                </div>
              )}
            </div>
          </div>
        ))}
        <div ref={chatEndRef} />
      </div>

      {/* Error Display */}
      {error && (
        <div className="p-2 text-sm text-center text-white bg-red-500">
          {error}
        </div>
      )}

      {/* Input Form */}
      <form onSubmit={handleSend} className="p-4 bg-white border-t">
        <div className="flex space-x-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Type your message..."
            className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={isLoading}
            className={`px-4 py-2 text-white bg-blue-600 rounded-lg ${
              isLoading ? 'opacity-50 cursor-not-allowed' : 'hover:bg-blue-700'
            }`}
          >
            {isLoading ? (
              <span className="inline-flex items-center">
                <svg className="w-4 h-4 mr-2 animate-spin" viewBox="0 0 24 24">
                  <circle
                    className="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    strokeWidth="4"
                    fill="none"
                  />
                  <path
                    className="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  />
                </svg>
                Sending...
              </span>
            ) : (
              'Send'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};